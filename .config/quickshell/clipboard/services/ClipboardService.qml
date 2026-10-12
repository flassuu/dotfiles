import QtQuick
import Quickshell
import Quickshell.Io

// Clipboard history engine on top of cliphist (text + images).
// Also owns the searchable/pinnable view model and the pin persistence file.
Scope {
    id: root

    property string binary: "cliphist"
    property bool available: false
    property bool loading: false
    property list<string> entries: []
    property var pins: []                 // raw cliphist entry lines, shown first
    // cliphist does not store timestamps (its db is a flat binary blob), so
    // the panel remembers when it first saw each entry id and ages it from
    // there. Without this every row showed the entry id formatted as a date
    // ("1/1/70").
    property var seen: ({})            // entry id -> unix seconds of first sight
    property string search: ""
    property bool injectPaste: true
    // Time between copying the entry to the clipboard and injecting Ctrl+V:
    // the panel needs a moment to close and hand keyboard focus back to the
    // previously focused window, otherwise the keypress lands on the dying
    // panel and nothing is pasted.
    property int pasteDelayMs: 250

    readonly property string pinsFile: "~/.cache/quickshell-clipboard/pins.txt"
    readonly property string previewsDir: "/tmp/quickshell-clipboard/previews"
    // Plain JS array of entry objects. Updated IMPERATIVELY from
    // onEntriesChanged/onPinsChanged/onSearchChanged: quickshell's compiler
    // does not track dependencies inside function-call bindings, so a
    // `property var model: computeModel()` binding would only evaluate once.
    // Quickshell injects each object into the delegate's
    // `required property var modelData` (roles/list models are unreliable).
    property var model: []

    onEntriesChanged: root.refreshModel()
    onPinsChanged: root.refreshModel()
    onSearchChanged: root.refreshModel()

    function refreshModel() {
        root.model = root.computeModel()
    }

    // Fired after a paste is requested so the shell can hide the panel
    // (focus goes back to the previous app) before Ctrl+V is injected.
    signal pasteRequested(string raw)

    function textOf(raw) {
        return raw.replace(/^\d+\t/, "")
    }
    function tsOf(raw) {
        const m = raw.match(/^(\d+)\t/)
        return m ? parseInt(m[1]) : 0
    }
    // cliphist renders binary entries as `ID\t[[ binary data 89 KiB png 544x1039 ]]`
    // (note the spaces around the marker) — the old pattern expected `[[binary`
    // without them and therefore never matched a single screenshot.
    function isImage(raw) {
        return /^\d+\t\[\[\s*binary data.*\]\s*\]$/.test(raw)
    }
    function imageMime(raw) {
        const m = raw.match(/\b(jpe?g|png|webp|gif|bmp)\b/i)
        if (!m) return "image/png"
        const kind = m[1].toLowerCase()
        return "image/" + (kind === "jpg" ? "jpeg" : kind)
    }
    function imageWidth(raw) {
        const m = raw.match(/(\d+)x(\d+)/)
        return m ? parseInt(m[1]) : 0
    }
    function imageHeight(raw) {
        const m = raw.match(/(\d+)x(\d+)/)
        return m ? parseInt(m[2]) : 0
    }
    function entryId(raw) {
        const m = raw.match(/^(\d+)\t/)
        return m ? m[1] : "0"
    }

    function fuzzyMatch(hay, needle) {
        if (!needle) return true
        const h = hay.toLowerCase()
        const n = needle.toLowerCase()
        if (h.includes(n)) return true
        let i = 0
        for (const ch of n) {
            const j = h.indexOf(ch, i)
            if (j < 0) return false
            i = j + 1
        }
        return true
    }

    function relTime(ts) {
        if (!ts) return "—"
        const d = Date.now() / 1000 - ts
        if (d < 60) return "just now"
        if (d < 3600) return Math.floor(d / 60) + " min ago"
        if (d < 86400) return Math.floor(d / 3600) + " h ago"
        const date = new Date(ts * 1000)
        return date.toLocaleDateString("en-US", { day: "2-digit", month: "short" })
    }

    // --- first-sight timestamps (cliphist has none) ---
    function timeOf(raw) {
        return root.seen[root.entryId(raw)] || 0
    }
    function rememberTimes() {
        const now = Math.floor(Date.now() / 1000)
        const live = new Set()
        let dirty = false
        for (const raw of root.entries) {
            const id = root.entryId(raw)
            live.add(id)
            if (root.seen[id] === undefined) {
                root.seen[id] = now
                dirty = true
            }
        }
        for (const id of Object.keys(root.seen)) {
            if (!live.has(id)) {
                delete root.seen[id]
                dirty = true
            }
        }
        if (dirty) {
            root.seen = Object.assign({}, root.seen)
            root.persistTimes()
        }
    }
    function persistTimes() {
        shCmd("mkdir -p ~/.cache/quickshell-clipboard && printf '%s' " + sq(JSON.stringify(root.seen))
            + " > ~/.cache/quickshell-clipboard/times.json")
    }
    function loadTimes() {
        timesProc.running = true
    }

    // Rebuilds the view model from entries + pins + search. Pinned entries go
    // first; everything is filtered by a substring/fuzzy search.
    function computeModel() {
        const q = root.search.trim().toLowerCase()
        const entrySet = new Set(root.entries)
        const pinned = root.pins.filter(p => entrySet.has(p))
        const pinnedSet = new Set(pinned)
        const out = []
        const push = (raw, isPinned) => {
            if (!root.fuzzyMatch(root.textOf(raw), q)) return
            out.push({
                raw: raw,
                pinned: isPinned,
                isImage: root.isImage(raw),
                imageWidth: root.imageWidth(raw),
                imageHeight: root.imageHeight(raw),
            })
        }
        for (const raw of pinned) push(raw, true)
        for (let i = 0; i < root.entries.length; i++) {
            const raw = root.entries[i]
            if (pinnedSet.has(raw)) continue
            push(raw, false)
        }
        return out
    }

    function sq(str) {
        return "'" + String(str).replace(/'/g, "'\\''") + "'"
    }

    function shCmd(cmd) {
        Quickshell.execDetached(["bash", "-c", cmd])
    }

    function refresh() {
        listProc.buffer = []
        listProc.running = true
    }

    // Puts an entry on the system clipboard. Image entries are offered as real
    // images (a bare `wl-copy` pastes the PNG blob as unreadable text), with a
    // text fallback so text-only apps still get something.
    function decodeToClipboard(raw) {
        const pipe = "printf '%s' " + sq(raw) + " | " + root.binary + " decode"
        if (isImage(raw)) {
            return pipe + " | wl-copy --type " + imageMime(raw) + " --type 'text/plain;charset=utf-8'"
        }
        return pipe + " | wl-copy"
    }

    // Ctrl+V through ydotool, but only while its daemon is alive: injecting
    // into nothing loses the keystroke silently.
    function injectCommand() {
        if (!root.injectPaste) return "true"
        return "if pgrep -x ydotoold >/dev/null 2>&1; then ydotool key 29:1 47:1 47:0 29:0 2>/dev/null; fi"
    }

    function copy(raw) {
        root.loading = true
        shCmd(root.decodeToClipboard(raw))
        Qt.callLater(() => root.loading = false)
    }

    function paste(raw) {
        shCmd(root.decodeToClipboard(raw) + " && sleep "
            + (root.pasteDelayMs / 1000).toFixed(2) + " && " + root.injectCommand())
        root.pasteRequested(raw)
    }

    function deleteEntry(raw) {
        runClip("printf '%s' " + sq(raw) + " | " + root.binary + " delete", true)
    }

    function wipe() {
        runClip(root.binary + " wipe", true)
    }

    function runClip(cmd, refreshAfter) {
        actionProc.command = ["bash", "-c", cmd]
        actionProc.refreshAfter = refreshAfter
        actionProc.running = true
    }

    // --- pins ---
    function isPinned(raw) {
        return root.pins.includes(raw)
    }
    function pinToggle(raw) {
        const idx = root.pins.indexOf(raw)
        if (idx >= 0) root.pins.splice(idx, 1)
        else root.pins.push(raw)
        root.pins = [...root.pins] // reassign so onPinsChanged fires
        root.persistPins()
    }
    function persistPins() {
        const quoted = root.pins.map(p => root.sq(p))
        const body = quoted.length ? "printf '%s\\n' " + quoted.join(" ") : "printf ''"
        shCmd("mkdir -p ~/.cache/quickshell-clipboard && " + body + " > " + root.pinsFile)
    }
    function loadPins() {
        root.pins = []
        readPins.running = true
    }

    Process {
        id: listProc
        property var buffer: []
        command: [root.binary, "list"]
        stdout: SplitParser {
            onRead: (line) => {
                if (line) listProc.buffer.push(line)
            }
        }
        onExited: (exitCode) => {
            if (exitCode === 0) {
                root.entries = listProc.buffer
                root.available = true
                root.rememberTimes()
                // Drop pins whose entry no longer exists in the history
                // (e.g. it was wiped or deleted), so stale rows can't linger.
                const entrySet = new Set(root.entries)
                if (root.pins.some(p => !entrySet.has(p))) {
                    root.pins = root.pins.filter(p => entrySet.has(p))
                    root.persistPins()
                }
            } else {
                root.available = false
                console.error("[Clipboard] '" + root.binary + "' failed with code", exitCode)
            }
            root.loading = false
            listProc.buffer = []
        }
    }

    Process {
        id: actionProc
        property bool refreshAfter: true
        command: ["bash", "-c", "true"]
        onExited: () => {
            if (actionProc.refreshAfter) refreshTimer.restart()
        }
    }

    Timer {
        id: refreshTimer
        interval: 80
        onTriggered: root.refresh()
    }

    Process {
        id: readPins
        property var buffer: []
        command: ["bash", "-c", "[ -f " + root.pinsFile + " ] && cat " + root.pinsFile]
        stdout: SplitParser {
            onRead: (line) => {
                if (line && !readPins.buffer.includes(line)) readPins.buffer.push(line)
            }
        }
        onExited: {
            root.pins = readPins.buffer
            readPins.buffer = []
        }
    }

    Process {
        id: timesProc
        command: ["bash", "-c", "[ -f ~/.cache/quickshell-clipboard/times.json ] && cat ~/.cache/quickshell-clipboard/times.json"]
        stdout: SplitParser {
            onRead: (line) => {
                if (!line) return
                try {
                    root.seen = JSON.parse(line)
                } catch (e) {
                    console.error("[Clipboard] bad times.json:", e.message)
                }
            }
        }
    }

    Component.onCompleted: {
        loadPins()
        loadTimes()
        refresh()
    }
}
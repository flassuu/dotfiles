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
    property var pins: []                 // JS array of raw cliphist entries
    property string search: ""
    property bool injectPaste: true
    property int pasteDelayMs: 180

    readonly property string pinsFile: "~/.cache/quickshell-clipboard/pins.txt"
    readonly property string previewsDir: "/tmp/quickshell-clipboard/previews"
    readonly property var model: computeModel()

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
    function isImage(raw) {
        return /^\d+\t\[\[binary data.*\]\]$/.test(raw)
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
        const d = Date.now() / 1000 - ts
        if (d < 60) return "только что"
        if (d < 3600) return Math.floor(d / 60) + " мин назад"
        if (d < 86400) return Math.floor(d / 3600) + " ч назад"
        const date = new Date(ts * 1000)
        return date.toLocaleDateString("ru-RU", { day: "2-digit", month: "short" })
    }

    function computeModel() {
        const q = root.search.trim().toLowerCase()
        const pinned = [...root.pins]
        const pinnedSet = new Set(pinned)
        const out = []
        const push = (raw, pinned) => {
            if (!root.fuzzyMatch(root.textOf(raw), q)) return
            out.push({
                raw: raw,
                pinned: pinned,
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

    function copy(raw) {
        root.loading = true
        shCmd("printf '%s' " + sq(raw) + " | " + root.binary + " decode | wl-copy")
        Qt.callLater(() => root.loading = false)
    }

    function paste(raw) {
        shCmd("printf '%s' " + sq(raw) + " | " + root.binary + " decode | wl-copy && sleep "
            + (root.pasteDelayMs / 1000).toFixed(2) + " && (command -v ydotool >/dev/null && ydotool key 29:1 47:1 47:0 29:0 || true)")
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
        command: ["bash", "-c", "[ -f " + root.pinsFile + " ] && cat " + root.pinsFile]
        stdout: SplitParser {
            onRead: (line) => {
                if (line && !root.pins.includes(line)) root.pins.push(line)
            }
        }
    }

    Component.onCompleted: {
        loadPins()
        refresh()
    }
}
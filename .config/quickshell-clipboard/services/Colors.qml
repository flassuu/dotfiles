import QtQuick
import Quickshell
import Quickshell.Io

// Loads the Matugen palette from ~/.cache/matugen/colors.css and maps it
// to Material-ish tokens used across the panel. Colors follow the active
// system theme (matugen regenerates the file on every theme switch).
Scope {
    id: root

    // Tokens with sensible fallbacks (used before the first palette load).
    property color bg: "#111314"
    property color surface: "#1b1d1e"
    property color surfaceRaised: "#232527"
    property color border: "#303334"
    property color fg: "#e8e6e3"
    property color fgMuted: "#9aa0a6"
    property color accent: "#7aa2f7"
    property color accentMuted: "#314061"
    property color danger: "#e06c75"

    // Polling is enabled while the panel is open so a live theme switch
    // is picked up immediately.
    property bool active: false

    readonly property string paletteFile: "~/.cache/matugen/colors.css"

    function refresh() {
        loader.buffer = []
        loader.running = true
    }

    function mix(c1, c2, t) {
        const h1 = c1.toString().replace("#", "")
        const h2 = c2.toString().replace("#", "")
        const a = [0, 2, 4].map(i => parseInt(h1.substr(i, 2), 16))
        const b = [0, 2, 4].map(i => parseInt(h2.substr(i, 2), 16))
        const r = Math.round(a[0] * t + b[0] * (1 - t))
        const g = Math.round(a[1] * t + b[1] * (1 - t))
        const bl = Math.round(a[2] * t + b[2] * (1 - t))
        const hex = "#" + [r, g, bl].map(v => v.toString(16).padStart(2, "0")).join("")
        return hex
    }

    function applyCss(css) {
        const map = {}
        const re = /--([\w-]+):\s*(#[0-9a-fA-F]{3,8})\s*;?/g
        let m
        while ((m = re.exec(css)) !== null) map[m[1]] = m[2]
        const p = map
        if (p.background) root.bg = p.background
        if (p.surface) root.surface = p.surface
        if (p.surface2) root.surfaceRaised = p.surface2
        if (p.surface3) root.border = p.surface3
        if (p.foreground) root.fg = p.foreground
        if (p.foreground && p.background) root.fgMuted = root.mix(p.foreground, p.background, 0.55)
        if (p.primary) root.accent = p.primary
        if (p.primary && p.surface) root.accentMuted = root.mix(p.primary, p.surface, 0.22)
        if (p.error) root.danger = p.error
    }

    Process {
        id: loader
        property var buffer: []
        command: ["bash", "-c", "cat " + root.paletteFile]
        stdout: SplitParser {
            onRead: (line) => loader.buffer.push(line)
        }
        onExited: (exitCode) => {
            if (exitCode === 0) {
                root.applyCss(loader.buffer.join("\n"))
            } else {
                console.error("[Colors] failed to read palette:", root.paletteFile)
            }
            loader.buffer = []
        }
    }

    Timer {
        interval: 1600
        repeat: true
        running: root.active
        onTriggered: root.refresh()
    }

    Component.onCompleted: root.refresh()
}
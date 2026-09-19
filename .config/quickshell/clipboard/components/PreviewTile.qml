import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io

// Decodes one image clipboard entry to a cached PNG in /tmp and shows it
// with rounded corners. The decode runs once per entry id (file is cached).
Rectangle {
    id: tile

    property string raw: ""
    property int tileRadius: 8

    readonly property string filePath: "/tmp/quickshell-clipboard/previews/" + entryId() + ".png"

    function entryId() {
        const m = tile.raw.match(/^(\d+)\t/)
        return m ? m[1] : "0"
    }

    color: "transparent"
    radius: tile.tileRadius

    Component.onCompleted: {
        // Only image entries (cliphist binary data blobs) can be decoded.
        // Plain text entries must never reach `cliphist decode`.
        if (/^\d+\t\[\[binary data.*\]\]$/.test(tile.raw)) {
            decodeProc.running = true
        }
    }

    Process {
        id: decodeProc
        command: ["bash", "-c",
            "mkdir -p /tmp/quickshell-clipboard/previews && "
            + "[ -f " + tile.filePath + " ] || printf '%s' "
            + "'" + tile.raw.replace(/'/g, "'\\''") + "'"
            + " | cliphist decode > " + tile.filePath]
        onExited: (exitCode) => {
            if (exitCode === 0) {
                image.source = "file://" + tile.filePath
            } else {
                console.error("[PreviewTile] decode failed")
            }
        }
    }

    Image {
        id: image
        anchors.fill: tile
        source: ""
        fillMode: Image.PreserveAspectCrop
        sourceSize.width: tile.width * 2
        sourceSize.height: tile.height * 2
        asynchronous: true
        visible: image.status === Image.Ready
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: image.width
                height: image.height
                radius: tile.tileRadius
            }
        }
    }

    // Rounded frame placeholder while decoding / on failure.
    Rectangle {
        anchors.fill: tile
        radius: tile.tileRadius
        color: "#00000000"
        border.width: 1
        visible: image.status !== Image.Ready
    }
}
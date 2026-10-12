import QtQuick
import QtQuick.Layouts

// One clipboard history row: preview tile, content line, meta line and
// hover actions (pin / paste / delete). Left click copies, double click pastes.
Rectangle {
    id: root

    // Quickshell injects the model item (one object of the JS-array model)
    // into this required property — this is the ONLY way delegates receive
    // data in this quickshell version (bare `model`/`modelData` are not in
    // scope, and ListModel role access is unreliable).
    required property var modelData
    property var entry: root.modelData
    property var service: null
    property var pal: null
    property bool isCurrent: false

    // Hover comes from the row MouseArea plus the action chips: a Rectangle
    // has no `hovered` property, so `root.hovered` was always undefined and
    // the row highlight / action chips never appeared on hover.
    readonly property bool hovered: mouse.containsMouse || chipRow.anyHovered

    // Fixed row height: a binding like `rowLayout.height + 12` created a
    // feedback loop (height of rowLayout depends on parent height) and made
    // every delegate collapse into a thin strip.
    implicitHeight: 52
    radius: 10

    color: root.isCurrent || root.hovered
        ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
    Behavior on color { ColorAnimation { duration: 120 } }

    // --- interaction ---
    // Declared BEFORE the content: later siblings stack on top in QML, so a
    // full-row MouseArea placed after the layout swallowed every click on the
    // pin/paste/delete chips (they appeared dead and only copied the row).
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        // no onWheel handler: wheel events fall through to the ListView
        acceptedButtons: Qt.LeftButton
        onClicked: {
            if (root.service) root.service.copy(root.entry.raw)
            root.copied = true
            copyTimer.restart()
        }
        onDoubleClicked: {
            if (root.service) root.service.paste(root.entry.raw)
        }
    }

    property bool copied: false
    Timer {
        id: copyTimer
        interval: 550
        onTriggered: root.copied = false
    }

    Rectangle {
        // Accent edge shown for the pinned entry.
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        width: 3
        height: root.entry.pinned ? 22 : 0
        radius: 1.5
        color: root.pal.accent
        Behavior on height { NumberAnimation { duration: 150 } }
    }

    RowLayout {
        id: rowLayout
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            leftMargin: 14
            rightMargin: 10
            topMargin: 6
            bottomMargin: 6
        }
        spacing: 12

        // --- leading tile ---
        Rectangle {
            id: tile
            Layout.preferredWidth: root.entry.isImage ? 72 : 40
            Layout.preferredHeight: 40
            radius: 9
            color: root.entry.pinned ? root.pal.accentMuted : root.pal.surfaceRaised
            Behavior on color { ColorAnimation { duration: 140 } }

            PreviewTile {
                anchors.fill: tile
                visible: root.entry.isImage
                raw: root.entry.raw
            }

            Text {
                anchors.centerIn: tile
                visible: !root.entry.isImage
                text: root.service.textOf(root.entry.raw).trim().charAt(0).toUpperCase() || "?"
                color: root.entry.pinned ? root.pal.accent : root.pal.fg
                font.family: "monospace"
                font.bold: true
                font.pixelSize: 15
            }

            Rectangle {
                // "copied" feedback badge
                anchors.fill: tile
                radius: tile.radius
                visible: root.copied
                color: Qt.rgba(0, 0, 0, 0.55)
                Text {
                    anchors.centerIn: parent
                    text: "✓"
                    color: root.pal.accent
                    font.pixelSize: 18
                    font.bold: true
                }
            }
        }

        // --- content ---
        Column {
            Layout.fillWidth: true
            spacing: 3

            Text {
                width: parent.width
                elide: Text.ElideMiddle
                text: root.entry.isImage
                    ? "Image · " + root.entry.imageWidth + "×" + root.entry.imageHeight
                    : root.service.textOf(root.entry.raw).replace(/\s+/g, " ")
                color: root.pal.fg
                font.family: "monospace"
                font.pixelSize: 13
                maximumLineCount: 1
            }

            Text {
                width: parent.width
                elide: Text.ElideRight
                text: (root.entry.pinned ? "★ · " : "") + root.service.relTime(root.service.timeOf(root.entry.raw))
                color: root.pal.fgMuted
                font.family: "monospace"
                font.pixelSize: 11
            }
        }

        // --- hover actions ---
        Row {
            id: chipRow
            // Keeps the row "hovered" while the cursor is on a chip, so the
            // chips don't disappear when the pointer enters them.
            property bool anyHovered: pinChip.hovered || pasteChip.hovered || delChip.hovered
            readonly property bool show: root.hovered || root.isCurrent || chipRow.anyHovered
            Layout.alignment: Qt.AlignVCenter
            spacing: 6
            visible: chipRow.show
            opacity: chipRow.show ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 100 } }

            ActionChip {
                id: pinChip
                text: "★"
                active: root.entry.pinned
                accent: root.pal.accent
                activeColor: root.pal.accent
                onTriggered: root.pinRequested(root.entry.raw)
            }
            ActionChip {
                id: pasteChip
                text: "⏎"
                accent: root.pal.fg
                onTriggered: root.pasteRequested(root.entry.raw)
            }
            ActionChip {
                id: delChip
                text: "✕"
                accent: root.pal.fgMuted
                activeColor: root.pal.danger
                onTriggered: root.deleteRequested(root.entry.raw)
            }
        }
    }

    // Signals bubbled to the shell.
    signal copyRequested(string raw)
    signal pasteRequested(string raw)
    signal deleteRequested(string raw)
    signal pinRequested(string raw)
}
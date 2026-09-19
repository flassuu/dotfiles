//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland

import "services"
import "components"

// Clipboard history panel (quickshell + cliphist).
// The config root is the PanelWindow itself: a plain Item root would be
// wrapped by quickshell into a stray floating window ("ProxyFloatingWindow").
PanelWindow {
    id: panel
    visible: panel.open

    Colors { id: theme }
    ClipboardService { id: clipSvc }

    // Keep theme polling active only while the panel is open.
    Binding { target: theme; property: "active"; value: panel.open }

    // Hide the panel right before Ctrl+V is injected by ydotool.
    Connections {
        target: clipSvc
        function onPasteRequested() { panel.closePanel() }
    }

    // IPC surface used by hyprland keybinds: "quickshell ipc call clipboardPanel toggle"
    IpcHandler {
        target: "clipboardPanel"
        function toggle(): void { panel.toggleOpen() }
        function open(): void { panel.openPanel() }
        function reload(): void { theme.refresh(); clipSvc.refresh(); clipSvc.loadPins() }
        function debug(): void {
            console.log("[DBG] avail=" + clipSvc.available + " entries=" + clipSvc.entries.length
                + " model=" + clipSvc.model.length + " pins=" + clipSvc.pins.length
                + " loading=" + clipSvc.loading
                + " search='" + clipSvc.search + "'"
                + " first=" + (clipSvc.entries.length ? clipSvc.textOf(clipSvc.entries[0]) : "none"))
        }
    }

    // Show on the focused monitor so the popup follows the user.
    // Re-assigned in openPanel() so every open re-evaluates the focus.
    function currentScreen() {
        const f = Hyprland.focusedMonitor
        if (!f) return null
        const ss = Quickshell.screens
        for (let i = 0; i < ss.length; i++) {
            if (ss[i].name === f.name) return ss[i]
        }
        return null
    }
    screen: panel.currentScreen()

    WlrLayershell.namespace: "quickshell:clipboard"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: panel.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    property bool open: false

    function currentRaw() {
        if (inputList.count === 0) return ""
        const item = clipSvc.model[inputList.currentIndex]
        return item ? item.raw : ""
    }
    function currentCopy() {
        const raw = currentRaw()
        if (raw) clipSvc.copy(raw)
    }
    function currentPaste() {
        const raw = currentRaw()
        if (raw) clipSvc.paste(raw)
    }
    function openPanel() {
        clipSvc.refresh()
        theme.refresh()
        searchInput.text = ""
        clipSvc.search = ""
        panel.screen = panel.currentScreen()
        panel.open = true
        inputList.currentIndex = 0
        Qt.callLater(() => searchInput.forceActiveFocus())
    }
    function closePanel() {
        panel.open = false
    }
    function toggleOpen() {
        if (panel.open) closePanel()
        else openPanel()
    }

    // Transparent backdrop: click outside the card closes the panel.
    MouseArea {
        anchors.fill: parent
        z: 0
        onClicked: panel.closePanel()
    }

    // --- The card ---
    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(640, parent.width - 40)
        height: Math.min(560, parent.height - 32)
        z: 1
        radius: 18
        color: theme.surface
        border.width: 1
        border.color: theme.border
        Behavior on color { ColorAnimation { duration: 200 } }
        Behavior on border.color { ColorAnimation { duration: 200 } }

        opacity: panel.open ? 1 : 0
        scale: panel.open ? 1 : 0.97
        visible: panel.open
        Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 170; easing.type: Easing.OutCubic } }

        // Swallows clicks on card padding so they don't reach the backdrop.
        MouseArea {
            anchors.fill: parent
            z: 0
            acceptedButtons: Qt.LeftButton
            onClicked: {}
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: 14
            anchors.bottomMargin: 10
            spacing: 0
            z: 1

            // ---------- header ----------
            RowLayout {
                id: headerRow
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 12
                spacing: 10
                property bool wipeArmed: false

                Rectangle {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    radius: 8
                    color: theme.accentMuted
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Text {
                        anchors.centerIn: parent
                        text: "⧉"
                        color: theme.accent
                        font.pixelSize: 15
                        font.bold: true
                    }
                }
                Text {
                    text: "Clipboard History"
                    color: theme.fg
                    font.family: "monospace"
                    font.pixelSize: 15
                    font.bold: true
                }
                Text {
                    text: clipSvc.available ? String(clipSvc.entries.length) : "—"
                    color: theme.fgMuted
                    font.family: "monospace"
                    font.pixelSize: 11
                }

                Item { Layout.fillWidth: true }

                HeaderButton {
                    text: "🗑"
                    iconColor: theme.fgMuted
                    pressedColor: theme.danger
                    onTriggered: {
                        if (!headerRow.wipeArmed) {
                            headerRow.wipeArmed = true
                            wipeArmTimer.restart()
                        } else {
                            clipSvc.wipe()
                            headerRow.wipeArmed = false
                        }
                    }
                    Rectangle {
                        y: 17; height: 15; width: 64
                        anchors.horizontalCenter: parent.horizontalCenter
                        radius: 4
                        color: theme.surfaceRaised
                        visible: headerRow.wipeArmed
                        Behavior on visible { NumberAnimation { duration: 80 } }
                        Text {
                            anchors.centerIn: parent
                            text: "wipe all?"
                            color: theme.danger
                            font.pixelSize: 10
                            font.family: "monospace"
                        }
                    }
                }
                Timer {
                    id: wipeArmTimer
                    interval: 1800
                    onTriggered: headerRow.wipeArmed = false
                }

                HeaderButton {
                    text: "✕"
                    iconColor: theme.fg
                    pressedColor: theme.danger
                    onTriggered: panel.closePanel()
                }
            }

            // ---------- search ----------
            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 14
                Layout.rightMargin: 14
                Layout.topMargin: 12
                Layout.preferredHeight: 42
                radius: 10
                color: theme.surfaceRaised
                border.width: 1
                border.color: theme.border
                Behavior on color { ColorAnimation { duration: 200 } }
                Behavior on border.color { ColorAnimation { duration: 200 } }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: "⌕"
                    color: theme.fgMuted
                    font.pixelSize: 16
                }

                QQC.TextField {
                    id: searchInput
                    anchors.fill: parent
                    anchors.leftMargin: 34
                    anchors.rightMargin: 10
                    verticalAlignment: Qt.AlignVCenter
                    color: theme.fg
                    font.family: "monospace"
                    font.pixelSize: 13
                    clip: true
                    placeholderText: "Search clipboard…"
                    placeholderTextColor: theme.fgMuted
                    background: Item {}

                    onTextChanged: {
                        clipSvc.search = text
                        if (inputList.count > 0) {
                            inputList.currentIndex = 0
                            inputList.positionViewAtIndex(0, ListView.Beginning)
                        }
                    }

                    Keys.onPressed: (event) => {
                        switch (event.key) {
                        case Qt.Key_Escape:
                            event.accepted = true
                            panel.closePanel()
                            break
                        case Qt.Key_Down:
                            event.accepted = true
                            if (inputList.currentIndex < inputList.count - 1)
                                inputList.currentIndex++
                            inputList.positionViewAtIndex(inputList.currentIndex, ListView.Center)
                            break
                        case Qt.Key_Up:
                            event.accepted = true
                            if (inputList.currentIndex > 0)
                                inputList.currentIndex--
                            inputList.positionViewAtIndex(inputList.currentIndex, ListView.Center)
                            break
                        case Qt.Key_Return:
                        case Qt.Key_Enter:
                            event.accepted = true
                            if (event.modifiers & Qt.ControlModifier)
                                panel.currentPaste()
                            else
                                panel.currentCopy()
                            break
                        case Qt.Key_Delete:
                            event.accepted = true
                            if (panel.currentRaw()) clipSvc.deleteEntry(panel.currentRaw())
                            break
                        case Qt.Key_P:
                            if (event.modifiers & Qt.ControlModifier) {
                                event.accepted = true
                                if (panel.currentRaw()) clipSvc.pinToggle(panel.currentRaw())
                            }
                            break
                        }
                    }
                }
            }

            // ---------- list ----------
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 10
                Layout.leftMargin: 8
                Layout.rightMargin: 8

                ListView {
                    id: inputList
                    anchors.fill: parent
                    clip: true
                    spacing: 3
                    model: clipSvc.model
                    currentIndex: 0
                    highlightMoveDuration: 120

                    delegate: ClipItem {
                        width: inputList.width
                        service: clipSvc
                        pal: theme
                        isCurrent: ListView.isCurrentItem
                        onCopyRequested: clipSvc.copy(raw)
                        onPasteRequested: clipSvc.paste(raw)
                        onDeleteRequested: clipSvc.deleteEntry(raw)
                        onPinRequested: clipSvc.pinToggle(raw)
                    }

                    // thin custom scrollbar
                    Rectangle {
                        anchors.right: parent.right
                        anchors.rightMargin: 2
                        width: 3
                        radius: 1.5
                        color: theme.border
                        visible: inputList.contentHeight > inputList.height
                        height: Math.max(24, inputList.height * inputList.height / inputList.contentHeight)
                        y: (inputList.contentY / Math.max(1, inputList.contentHeight - inputList.height))
                           * (inputList.height - height)
                    }
                }

                // ---------- empty / help states ----------
                Item {
                    id: emptyState
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    z: 2
                    visible: inputList.count === 0 && panel.open

                    function stateText() {
                        if (!clipSvc.available) return "cliphist is not installed"
                        if (clipSvc.search.trim() !== "") return "No matches"
                        return "History is empty"
                    }
                    function stateSub() {
                        if (!clipSvc.available)
                            return "sudo pacman -S cliphist\nThen restart the session."
                        if (clipSvc.search.trim() !== "") return ""
                        return "Copy some text or take a screenshot,\nand it will show up here."
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width - 24
                        radius: 12
                        color: theme.surfaceRaised
                        Behavior on color { ColorAnimation { duration: 200 } }
                        Column {
                            anchors.centerIn: parent
                            spacing: 8
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: emptyState.stateText()
                                color: theme.fg
                                font.family: "monospace"
                                font.pixelSize: 14
                                font.bold: true
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 300
                                wrapMode: Text.WordWrap
                                horizontalAlignment: Text.AlignHCenter
                                color: theme.fgMuted
                                font.family: "monospace"
                                font.pixelSize: 11
                                text: emptyState.stateSub()
                            }
                        }
                    }
                }
            }

            // ---------- footer hints ----------
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 26
                Layout.topMargin: 2
                Column {
                    anchors.centerIn: parent
                    spacing: 1
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Enter — copy · Ctrl+Enter — paste · Del — delete · Ctrl+P — pin"
                        color: theme.fgMuted
                        font.family: "monospace"
                        font.pixelSize: 10
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "click — copy · double click — paste · Esc — close"
                        color: theme.fgMuted
                        font.family: "monospace"
                        font.pixelSize: 10
                    }
                }
            }
        }
    }
}
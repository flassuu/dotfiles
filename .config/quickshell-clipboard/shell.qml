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

Item {
    id: root
    visible: false

    Colors { id: palette }
    ClipboardService { id: clip }

    // Keep palette polling active only while the panel is open.
    Binding { target: palette; property: "active"; value: panel.open }

    // Hide the panel right before Ctrl+V is injected by ydotool.
    Connections {
        target: clip
        function onPasteRequested() { panel.closePanel() }
    }

    // IPC surface used by hyprland keybinds: "quickshell ipc call clipboardPanel toggle"
    IpcHandler {
        target: "clipboardPanel"
        function toggle(): void { panel.toggleOpen() }
        function open(): void { panel.openPanel() }
        function reload(): void { palette.refresh(); clip.refresh(); clip.loadPins() }
    }

    PanelWindow {
        id: panel
        visible: panel.open

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
            return clip.model[inputList.currentIndex].raw
        }
        function currentCopy() {
            const raw = currentRaw()
            if (raw) clip.copy(raw)
        }
        function currentPaste() {
            const raw = currentRaw()
            if (raw) clip.paste(raw)
        }
        function openPanel() {
            clip.refresh()
            palette.refresh()
            searchInput.text = ""
            clip.search = ""
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
            color: palette.surface
            border.width: 1
            border.color: palette.border
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
                        color: palette.accentMuted
                        Behavior on color { ColorAnimation { duration: 200 } }
                        Text {
                            anchors.centerIn: parent
                            text: "⧉"
                            color: palette.accent
                            font.pixelSize: 15
                            font.bold: true
                        }
                    }
                    Text {
                        text: "История буфера"
                        color: palette.fg
                        font.family: "monospace"
                        font.pixelSize: 15
                        font.bold: true
                    }
                    Text {
                        text: clip.available ? String(clip.entries.length) : "—"
                        color: palette.fgMuted
                        font.family: "monospace"
                        font.pixelSize: 11
                    }

                    Item { Layout.fillWidth: true }

                    HeaderButton {
                        text: "🗑"
                        iconColor: palette.fgMuted
                        pressedColor: palette.danger
                        onTriggered: {
                            if (!headerRow.wipeArmed) {
                                headerRow.wipeArmed = true
                                wipeArmTimer.restart()
                            } else {
                                clip.wipe()
                                headerRow.wipeArmed = false
                            }
                        }
                        Rectangle {
                            y: 17; height: 15; width: 64
                            anchors.horizontalCenter: parent.horizontalCenter
                            radius: 4
                            color: palette.surfaceRaised
                            visible: headerRow.wipeArmed
                            Behavior on visible { NumberAnimation { duration: 80 } }
                            Text {
                                anchors.centerIn: parent
                                text: "очистить?"
                                color: palette.danger
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
                        iconColor: palette.fg
                        pressedColor: palette.danger
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
                    color: palette.surfaceRaised
                    border.width: 1
                    border.color: palette.border
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Behavior on border.color { ColorAnimation { duration: 200 } }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: "⌕"
                        color: palette.fgMuted
                        font.pixelSize: 16
                    }

                    QQC.TextField {
                        id: searchInput
                        anchors.fill: parent
                        anchors.leftMargin: 34
                        anchors.rightMargin: 10
                        verticalAlignment: Qt.AlignVCenter
                        color: palette.fg
                        font.family: "monospace"
                        font.pixelSize: 13
                        clip: true
                        placeholderText: "Поиск по буферу…"
                        placeholderTextColor: palette.fgMuted
                        background: Item {}

                        onTextChanged: {
                            clip.search = text
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
                                if (panel.currentRaw()) clip.deleteEntry(panel.currentRaw())
                                break
                            case Qt.Key_P:
                                if (event.modifiers & Qt.ControlModifier) {
                                    event.accepted = true
                                    if (panel.currentRaw()) clip.pinToggle(panel.currentRaw())
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
                        model: clip.model
                        currentIndex: 0
                        highlightMoveDuration: 120

                        delegate: ClipItem {
                            width: inputList.width
                            entry: modelData
                            service: clip
                            pal: palette
                            isCurrent: ListView.isCurrentItem
                            onCopyRequested: clip.copy(raw)
                            onPasteRequested: clip.paste(raw)
                            onDeleteRequested: clip.deleteEntry(raw)
                            onPinRequested: clip.pinToggle(raw)
                        }

                        // thin custom scrollbar
                        Rectangle {
                            anchors.right: parent.right
                            anchors.rightMargin: 2
                            width: 3
                            radius: 1.5
                            color: palette.border
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
                            if (!clip.available) return "cliphist не установлен"
                            if (clip.search.trim() !== "") return "Ничего не найдено"
                            return "История пуста"
                        }
                        function stateSub() {
                            if (!clip.available)
                                return "sudo pacman -S cliphist\nзатем перезапусти сессию"
                            if (clip.search.trim() !== "") return ""
                            return "Скопируй текст или сделай скриншот,\nи запись появится здесь."
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width - 24
                            radius: 12
                            color: palette.surfaceRaised
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Column {
                                anchors.centerIn: parent
                                spacing: 8
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: emptyState.stateText()
                                    color: palette.fg
                                    font.family: "monospace"
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 300
                                    wrapMode: Text.WordWrap
                                    horizontalAlignment: Text.AlignHCenter
                                    color: palette.fgMuted
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
                            text: "Enter — копировать · Ctrl+Enter — вставить · Del — удалить · Ctrl+P — закрепить"
                            color: palette.fgMuted
                            font.family: "monospace"
                            font.pixelSize: 10
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "клик — копия · двойной клик — вставка · Esc — закрыть"
                            color: palette.fgMuted
                            font.family: "monospace"
                            font.pixelSize: 10
                        }
                    }
                }
            }
        }
    }
}
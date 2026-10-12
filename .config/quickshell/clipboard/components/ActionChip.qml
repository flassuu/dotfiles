import QtQuick

// Small circular icon button used for row actions.
// Icons are plain symbols, not emoji: the monospace font has no emoji
// coverage, so 📌/🗑 render as empty tofu boxes.
Rectangle {
    id: chip
    property string text: ""
    property var accent: "#ffffff"
    property bool active: false
    property var activeColor: accent
    signal triggered()

    width: 26
    height: 26
    radius: 8

    // Hover state must be read from the MouseArea: a Rectangle has no
    // `hovered` property, so `chip.hovered` used to be undefined and the
    // hover highlight never appeared.
    readonly property bool hovered: mouse.containsMouse
    readonly property bool highlighted: chip.hovered || chip.active

    color: chip.highlighted ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
    Behavior on color { ColorAnimation { duration: 100 } }

    Text {
        anchors.centerIn: parent
        text: chip.text
        color: chip.active ? chip.activeColor : chip.accent
        font.pixelSize: 12
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        // Without this, QML propagates the click to the parent MouseArea of
        // the row: the chip action ran together with "copy", and the second
        // delivery was treated as a double click, which triggered paste and
        // closed the panel.
        propagateComposedEvents: false
        onClicked: chip.triggered()
    }
}
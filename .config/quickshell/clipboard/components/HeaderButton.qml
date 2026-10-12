import QtQuick

// Small square button used in the card header.
Rectangle {
    id: btn
    property string text: ""
    property var iconColor: "#ffffff"
    property var pressedColor: btn.iconColor
    signal triggered()

    width: 30
    height: 30
    radius: 8

    // Hover/press state comes from the MouseArea (Rectangle has no
    // `hovered` property; `down` used to be a manually toggled flag).
    readonly property bool hovered: mouse.containsMouse
    readonly property bool down: mouse.pressed

    color: btn.down
        ? Qt.rgba(1, 1, 1, 0.16)
        : (btn.hovered ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(1, 1, 1, 0))
    Behavior on color { ColorAnimation { duration: 100 } }

    Text {
        anchors.centerIn: parent
        text: btn.text
        color: btn.down ? btn.pressedColor : btn.iconColor
        font.pixelSize: 14
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        propagateComposedEvents: false
        onClicked: btn.triggered()
    }
}
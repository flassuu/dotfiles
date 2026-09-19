import QtQuick

// Small square button used in the card header.
Rectangle {
    id: btn
    property string text: ""
    property var iconColor: "#ffffff"
    property var pressedColor
    signal triggered()

    width: 30
    height: 30
    radius: 8
    color: btn.hovered
        ? Qt.rgba(1, 1, 1, 0.10)
        : Qt.rgba(1, 1, 1, 0)
    Behavior on color { ColorAnimation { duration: 100 } }

    Text {
        anchors.centerIn: parent
        text: btn.text
        color: btn.pressedColor !== undefined && btn.down ? btn.pressedColor : btn.iconColor
        font.pixelSize: 14
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: btn.down = true
        onReleased: btn.down = false
        onClicked: btn.triggered()
    }
    property bool down: false
}
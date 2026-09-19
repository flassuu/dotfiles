import QtQuick

// Small circular icon button used for row actions.
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
    color: chip.hovered
        ? Qt.rgba(1, 1, 1, 0.12)
        : (chip.active ? Qt.rgba(1, 1, 1, 0.12) : "transparent")
    Behavior on color { ColorAnimation { duration: 100 } }

    Text {
        anchors.centerIn: parent
        text: chip.text
        color: chip.active ? activeColor : accent
        font.pixelSize: 12
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: chip.triggered()
    }
}
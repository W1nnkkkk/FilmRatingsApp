import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.0

Rectangle {
    id: chip
    width: 110
    height: 30
    radius: 10

    Component.onCompleted: {
        chip.color = selected ? specialColor : "lightgrey"
    }

    WrappedText {
        id: text
        anchors.centerIn: parent
        text: chip.text
        font.pixelSize: 14
        color: (chip.selected) ? "#FFFFFF" : "#555555"
    }

    MouseArea {
        id: mainArrea
        anchors.fill: parent

        property bool isClickable: true

        onClicked: {
            if (isClickable) {
                chip.selected = !chip.selected
                backgroundColorAnimation.start()
                mainArrea.isClickable = false;
                clickTimer.start();
            }
        }

        Timer {
            id: clickTimer
            interval: 400
            running: false
            onTriggered: {
                mainArrea.isClickable = true;
            }
        }
    }

    ColorAnimation on color {
        id: backgroundColorAnimation
        from: chip.color
        to: selected ? "#228B22" : "lightgrey"
        duration: 400
    }

    property bool selected: false
    property string text: ""
}

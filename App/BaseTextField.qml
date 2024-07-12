import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.0

TextField {
    id: rootArea
    Layout.fillWidth: true
    selectByMouse: true
    placeholderTextColor: mainTextColor

    background: Rectangle {
        radius: 10
        color: "white"
        border.color: "lightgrey"
    }

    font.pixelSize: 16
    padding: 10
}




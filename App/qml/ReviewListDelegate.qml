import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.0

Rectangle {
    width: parent.width
    height: reviewName.height + comment.height + 30
    radius: 5

    Text {
        id: reviewName
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 10
        text: model.name
        font.bold: true
        font.family: headingFont
    }

    WrappedText {
        id: comment
        anchors.top: reviewName.bottom
        anchors.left: parent.left
        anchors.topMargin: 5
        anchors.leftMargin: 15
        text: model.comment
    }
}

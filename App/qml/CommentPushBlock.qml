import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.0
import Qt.labs.platform 1.0

Rectangle {
    id: rootRect
    Layout.fillWidth: true
    implicitHeight: showButton.height
    color: mainWindow.background.color

    property bool open : false

    Button {
        id: showButton
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        height: 40
        width: 50

        background: Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            height: 30
            width: 30
            color: scale ? "lightgrey" : mainWindow.background.color
            radius: 6
            id: backColor
        }

        Text {
            text: open ? "ᐯ" : "ᐱ"
            font.pointSize: 16
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Component.onCompleted: {
            backColor.scale = 0
        }

        onVisibleChanged: {
            backColor.scale = 0
        }

        onHoveredChanged: {
            circleAnimation(backColor, showButton.hovered)
        }

        onClicked: {
            open = !open
            addCommentRect.visible = open
            if (open) {
                openAnimation.start()
            } else {
                closeAnimation.start()
            }
        }
    }

    Rectangle {
        id: addCommentRect
        anchors {
            top: showButton.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 10
        }
        visible: false
        color: mainWindow.background.color

        ColumnLayout {
            id: addReview
            anchors.fill: parent
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                BaseTextField {
                    id: nameTextField
                    placeholderText: "Никнейм"
                }
                Button {
                    icon.source:
                        "https://cdn-icons-png.flaticon.com/128/149/149446.png"

                    background: Rectangle {
                        radius: 10
                        color: mainWindow.background.color
                        border.color: "lightgrey"
                    }

                    onClicked: {
                        if (checkEmptyText(nameTextField.text)
                                && commentTextField.text) {
                            requester.createReview(nameTextField.text,
                                                   commentTextField.text, id)
                            nameTextField.clear()
                            commentTextField.clear()
                            root.updFunc = requester.updateReviewModel
                            root.start()
                        }
                    }
                }
            }

            Rectangle {
                id: commentTextField
                property alias placeholderText : rootArea.placeholderText
                property alias text : rootArea.text
                property var clear: () => {
                    rootArea.clear()
                }
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 10
                color: "white"
                border.color: "lightgrey"

                Flickable {
                    anchors.fill: parent
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        right: parent.right
                        left: parent.left
                    }
                    TextArea.flickable: TextArea {
                        id: rootArea
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        selectByMouse: true
                        wrapMode: TextArea.WrapAtWordBoundaryOrAnywhere
                        placeholderText: "Отзыв"
                        placeholderTextColor: mainTextColor

                        font.pixelSize: 16
                    }
                    ScrollBar.vertical: ScrollBar { }
                }
            }
        }
    }


    NumberAnimation {
        id: openAnimation
        target: rootRect
        property: "implicitHeight"
        from: showButton.height
        to: 200
        duration: 400
        easing.type: Easing.InOutQuad
    }

    NumberAnimation {
        id: closeAnimation
        target: rootRect
        property: "implicitHeight"
        from: 200
        to: showButton.height
        duration: 400
        easing.type: Easing.InOutQuad
    }

}

import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.0

ToolBar {
    id: toolBar
    property alias returnButt : returnButt
    property alias hambMenu : hambRect
    property alias hambState : menuBackIcon.state

    background: Rectangle {
        anchors.fill: parent
        color: mainWindow.background.color
    }

    RowLayout {
        height: 48
        spacing: 10
        Rectangle {
            id: hambRect
            width: 48
            height: 48
            color: mainWindow.background.color

            onVisibleChanged: {
                hovered = false
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter

                width: 30
                height: 30
                radius: 6
                color: mouseArea.containsMouse ?
                           "lightgrey" : mainWindow.background.color

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        menuBackIcon.state = menuBackIcon.state ===
                                "menu" ? "back" : "menu"
                        sideBar.visible = !sideBar.visible
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }
            }

            HamburgerMenu {
                id: menuBackIcon
                anchors.centerIn: parent
            }
        }

        Rectangle {
            width: 48
            height: 48
            visible: true
            color: mainWindow.background.color
            Button {
                id: returnButt
                visible: false
                anchors.fill: parent
                onClicked: {
                    requester.findFilms(filter.getFilter())
                    requester.updateMovieModel()
                    showTextField(returnButt, false)
                    showTextField(hambMenu, true)
                    mainView.pop()
                }

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
                    text: "←"
                    font.pointSize: 16
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                onVisibleChanged: {
                    backColor.scale = 0
                }

                onHoveredChanged: {
                    circleAnimation(backColor, returnButt.hovered)
                }
            }
        }
    }

    PropertyAnimation {
        id: circleScaleAnimation
        property: "scale"
        from: 0
        to: 1
        duration: 200
        easing.type: Easing.InOutQuad
        running: false

        onFinished: {
            if (!hovered) {
                this.target.scale = 0
            }
        }
    }

    function circleAnimation(rect, hovered) {
        if (hovered) {
            circleScaleAnimation.target = rect
            circleScaleAnimation.running = true
        }
        else {
            rect.scale = 0
        }
    }

}

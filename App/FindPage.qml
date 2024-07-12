import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.0
import Qt.labs.platform 1.0

ColumnLayout {
    visible: false
    id: page3
    anchors.margins: 10

    property alias findName: findName
    property alias findDirector: findDirector
    property alias findStarring: findStarring
    property alias findYear: findYear
    property alias findCountry: findCountry
    property alias findGenre: findGenre


    Rectangle {
        id: findName
        radius: 10
        color: mainWindow.posterColor
        Layout.fillWidth: true
        Layout.margins: 10
        height: nameTextField.height + 2
        border.color: "lightgrey"
        visible: true

        property alias text: nameTextField.text

        RowLayout {
            anchors.fill: parent
            spacing: 5
            BaseTextField {
                id: nameTextField
                Layout.fillHeight: true
                Layout.margins: 1
                placeholderText: "Название фильма"

                background: Rectangle {
                    radius: 10
                    color: "white"
                }

            }
            Button {
                id: optionButton
                icon.source: "qrc:/icons/filter.png"
                Layout.alignment: Qt.AlignRight

                property bool open

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

                Component.onCompleted: {
                    backColor.scale = 0
                    open = false
                }

                onVisibleChanged: {
                    backColor.scale = 0
                }

                onHoveredChanged: {
                    circleAnimation(backColor, optionButton.hovered)
                }

                onClicked: {
                    open = !open
                    showOptions(open)
                }
            }
            Button {
                id: serachButton
                icon.source: "qrc:/icons/Search.svg"
                Layout.alignment: Qt.AlignRight

                height: 40
                width: 50

                background: Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter

                    height: 30
                    width: 30
                    color: scale ? "lightgrey" : mainWindow.background.color
                    radius: 6
                    id: backColorRect
                }

                Component.onCompleted: {
                    backColorRect.scale = 0
                }

                onVisibleChanged: {
                    backColorRect.scale = 0
                }

                onHoveredChanged: {
                    circleAnimation(backColorRect, serachButton.hovered)
                }

                onClicked: {
                    findFunc();
                }
            }
        }
    }

    Rectangle {
        Layout.fillHeight: true
        Layout.fillWidth: true
        color: mainWindow.background.color
        RowLayout {
            id: rowLayout
            anchors.fill: parent
            ColumnLayout {
                id: columnLayout
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop

                BaseTextField {
                    id: findDirector
                    visible: false
                    placeholderText: "Имя режисера"
                    Layout.margins: 10
                }

                BaseTextField {
                    id: findStarring
                    visible: false
                    placeholderText: "Имя звезды"
                    Layout.fillWidth: true
                    Layout.margins: 10
                }

                BaseTextField {
                    id: findYear
                    visible: false
                    placeholderText: "Год выпуска"
                    Layout.fillWidth: true
                    Layout.margins: 10
                }

                BaseTextField {
                    id: findCountry
                    visible: false
                    placeholderText: "Страна выпуска"
                    Layout.fillWidth: true
                    Layout.margins: 10
                }

                BaseTextField {
                    id: findGenre
                    visible: false
                    placeholderText: "Жанр"
                    Layout.fillWidth: true
                    Layout.margins: 10
                }
            }

            ChipsContainer {
                id: chipsContainer
                Layout.margins: 5
                Layout.alignment: Qt.AlignTop | Qt.AlignRight
                visible: false
            }
        }
    }

    function toArray(textToArray) {
        var arr = textToArray.split(", ");
        console.log(arr);
        return arr
    }

    function findFunc() {
        filter.clear()

        if (findName.text) {
            filter.insert("name", findName.text)
            nameTextField.clear()
        }
        if (findDirector.text) {
            filter.insert("director", findDirector.text)
            findDirector.clear()
        }
        if (findStarring.text) {
            filter.insert("starring", findStarring.text)
            findStarring.clear()
        }
        if (findYear.text) {
            filter.insert("year", findYear.text)
            findYear.clear()
        }
        if (findCountry.text) {
            filter.insert("country", findCountry.text)
            findCountry.clear()
        }
        if (findGenre.text) {
            filter.insert("genre", findGenre.text)
            findGenre.clear()
        }

        requester.findFilms(filter.getFilter())
        if (appLayout.visible) {
            root.updFunc = requester.updateMovieModel
            root.start()
            mainView.pop(filmListPage)
        }
        else {
            root.updFunc = requester.updateMovieModel
            root.start()
            findPage.visible = false
            appLayout.visible = true
        }
    }

    function showOptions(open) {
        showTextField(chipsContainer, open)
    }
}


import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.0

Rectangle {
    id: chipsContainer
    width: needWidth
    height: 40
    color: mainWindow.background.color

    property int counter: -1
    property int needWidth: 110

    Repeater {
        model: chipsModel
        anchors.fill: parent
        Chip {
            id: chip
            anchors.right: parent.right
            y: chip.y + (index * (height + 10))
            text: model.text
            selected: model.selected

            onSelectedChanged: {
                if (model.action === "showName") {
                    showTextField(page3.findName, !page3.findName.visible)
                }
                else if (model.action === "showDirector") {
                    showTextField(page3.findDirector, !page3.findDirector.visible)
                }
                else if (model.action === "showStarring") {
                    showTextField(page3.findStarring, !page3.findStarring.visible)
                }
                else if (model.action === "showYear") {
                    showTextField(page3.findYear, !page3.findYear.visible)
                }
                else if (model.action === "showCountry") {
                    showTextField(page3.findCountry, !page3.findCountry.visible)
                }
                else if (model.action === "showGenre") {
                    showTextField(page3.findGenre, !page3.findGenre.visible)
                }
            }
        }
    }

    ListModel {
        id: chipsModel
        property bool selected
        property string action
        property bool move

        ListElement {
            text: "Режжисер"
            selected: false
            action: "showDirector"
            move: false
        }
        ListElement {
            text: "Звезды"
            selected: false
            action: "showStarring"
            move: false
        }
        ListElement {
            text: "Год выпуска"
            selected: false
            action: "showYear"
            move: false
        }
        ListElement {
            text: "Страна выпуска"
            selected: false
            action: "showCountry"
            move: true
        }
        ListElement {
            text: "Жанры"
            selected: false
            action: "showGenre"
            move: true
        }
    }
}

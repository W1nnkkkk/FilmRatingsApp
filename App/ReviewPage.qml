import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.0

ColumnLayout {
    id: page2
    visible: false

    property alias image: mainImage.source
    property alias name: name.text
    property alias releaseDate: releaseDate.text
    property alias genre: genre.text
    property alias duration: duration.text
    property alias country: country.text
    property alias director: director.text
    property alias starring: starring.text
    property string id

    Rectangle {
        id: filmData
        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true
        height: mainImage.height + 60
        color: posterColor

        Image {
            id: mainImage
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 10
            width: 164
            height: mainImage.width - 10
            sourceSize: Qt.size(mainImage.width, mainImage.width)
            fillMode: Image.PreserveAspectFit
        }

        ColumnLayout {
            id: columnLayout
            clip: true
            width: parent.width - mainImage.width - 30
            spacing: 10
            anchors {
                left: mainImage.right
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                margins: 10
            }
            WrappedText {
                id: name
                Layout.topMargin: 5
                font.bold: true
                color: mainTextColor
                font.family: headingFont
            }
            WrappedText {
                id: duration
            }
            WrappedText {
                id: country
            }
            WrappedText
            {
                id: releaseDate
            }
            WrappedText {
                id: genre
            }
            WrappedText {
                id: director
            }
            WrappedText {
                id: starring
            }
        }
    }

    Rectangle {
        id: listView
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        color: background.color
        ListView {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10
            model: reviewModel
            delegate: ReviewListDelegate {
                id: delegate
            }
        }
    }

    CommentPushBlock {
        id: container
    }
}

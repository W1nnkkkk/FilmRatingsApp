import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.0

Rectangle {
    clip: true
    id: delegate
    radius: 10
    width: parent.width
    height: photo.height + 20
    // onParentChanged: {
    //     delegate.width = parent.width
    //     delegate.height = photo.height + 20
    // }
    Image {
        id: photo
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 10
        source: model.image
        width: 128
        height: photo.width
        sourceSize: Qt.size(photo.width, photo.width)
        fillMode: Image.PreserveAspectFit
    }
    ColumnLayout {
        id: mainLayout
        clip: true
        width: parent.width - photo.width - 30
        spacing: 5
        anchors {
            left: photo.right
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            margins: 10
        }
        WrappedText {
            Layout.topMargin: 5
            text: model.name ?
                      model.name : model.originalName
            font.bold: true
            color: mainTextColor
            font.family: headingFont
        }
        WrappedText
        {
            text: "Дата выпуска: " +
                  (model.releaseDate ? model.releaseDate : model.year)
        }
        WrappedText {
            text: "Жанры: " + model.genre
        }
        WrappedText {
            text: "Режиссер: " + model.director
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            requester.findReview(model.id)
            requester.updateReviewModel()
            sideBar.visible = false
            toolBar.hambState = "menu"
            toolBar.hambMenu.visible = false
            showTextField(toolBar.returnButt, true)
            reviewListPage.image = photo.source
            reviewListPage.name = model.name ? model.name : model.originalName
            reviewListPage.releaseDate = "Дата выпуска: " +
                    (model.releaseDate ? model.releaseDate : model.year)
            reviewListPage.genre = "Жанры: " + model.genre
            reviewListPage.duration = "Время просмотра: " + model.duration
            reviewListPage.country = "Страна выпуска: " + model.country
            reviewListPage.director = "Режиссер: " + model.director
            reviewListPage.starring = "В главных ролях: " + model.starring
            reviewListPage.id = model.id
            reviewListPage.visible = true
            mainView.push(reviewListPage)
        }
    }
}

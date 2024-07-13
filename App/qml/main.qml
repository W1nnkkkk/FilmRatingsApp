import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.0

ApplicationWindow {
    width: 480
    height: 700
    visible: true
    id: mainWindow
    title: qsTr("Films")

    property color mainTextColor: "#333333"
    property color posterColor: "#FFFFFF"
    property color specialColor: "#228B22"
    property string headingFont: "Poppins"

    background: Rectangle {
        id: background
        color: "#F5F5F5"
        anchors.fill: parent
    }

    RowLayout {
        id: appLayout
        anchors.fill: parent
        visible: false
        SideBar {
            id: sideBar
            visible : false
        }

        ColumnLayout {

            MainToolBar {
                id: toolBar
            }

            StackView {
                id: mainView
                Layout.fillHeight: true
                Layout.fillWidth: true
                initialItem: filmListPage
            }
        }

    }

    FilmListPage {
        id: filmListPage
        visible: false
    }

    ReviewPage {
        visible: false
        id: reviewListPage
    }

    FindPage {
        visible: true
        anchors.fill: parent
        id: findPage
    }


    NumberAnimation {
        id: fadeInAnimation
        property: "opacity"
        from: 0
        to: 1
        duration: 400
        easing.type: Easing.InOutQuad
        running: false
    }

    PropertyAnimation {
        id: scaleAnimation
        property: "scale"
        from: 0.1
        to: 1
        duration: 400
        easing.type: Easing.InOutQuad
        running: false
    }

    PropertyAnimation {
        id: inverslyScaleAnimation
        property: "scale"
        from: 1
        to: 0
        duration: 400
        easing.type: Easing.InOutQuad
        running: false

        onFinished: {
            this.target.visible = false;
        }
    }

    function showTextField(textField, show) {
        if (show) {
            textField.visible = true;
            fadeInAnimation.target = textField;
            fadeInAnimation.running = true;
            scaleAnimation.target = textField;
            scaleAnimation.running = true;
        } else {
            textField.opacity = 1;
            textField.visible = true;
            textField.scale = 1;
            inverslyScaleAnimation.target = textField;
            inverslyScaleAnimation.running = true;
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

        property var hovered

        onFinished: {
            if (!hovered) {
                this.target.scale = 0
            }
        }
    }

    function circleAnimation(rect, hovered) {
        if (hovered) {
            circleScaleAnimation.hovered = hovered
            circleScaleAnimation.target = rect
            circleScaleAnimation.running = true
        }
        else {
            rect.scale = 0
        }
    }

    function checkEmptyText(text) {
        if (text === "") {
            showPopup(errorPopup, "Не оставляйте поля пустыми")
            return false
        }
        else {
            return true
        }
    }

    Popup {
        id: errorPopup
        width: 200
        height: 80
        modal: true
        focus: true
        anchors.centerIn: parent

        property alias text: errorText.text

        Column {
            spacing: 10
            anchors.centerIn: parent

            WrappedText {
                id: errorText
                text: "Неверный ввод!"
                font.pixelSize: 14
                color: "black"
            }
        }

        NumberAnimation {
            id: fadeAnimation
            target: errorPopup
            property: "opacity"
            from: 0
            to: 1
            duration: 250
            easing.type: Easing.InOutQuad
            running: false
        }

        onVisibleChanged: {
            fadeAnimation.start();
        }
    }

    Timer {
        id: popupTimer
        interval: 1400
        repeat: false
        property var popup
        onTriggered: {
            popup.visible = false;
        }
    }

    function showPopup(popup, text) {
        popup.text = text
        popupTimer.popup = popup
        popup.visible = true
        popupTimer.start()
    }

    LoadingCircle {
        id: loadingCircle
        visible: false
    }

    Rectangle {
        id: root
        width: parent.width
        height: parent.height
        color: "#FFF"
        visible: false

        property var start : () => {
            root.visible = true
            mainView.visible = false
            timer.start()
        }

        property var updFunc

        Loader {
            id: loader
            source: "LoadingCircle.qml"
            anchors.centerIn: parent
        }

        Timer {
            id: timer
            interval: 1000
            running: true
            onTriggered: {
                loader.source = "LoadingCircle.qml"
                root.visible = false
                loader.item.visible = true
                root.updFunc()
                mainView.visible = true
            }
        }
    }

}

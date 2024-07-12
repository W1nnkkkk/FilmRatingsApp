import QtQuick 2.9

Item {
    id: root

    property alias barsColor: root.bcolor
    property color bcolor: "black"
    property real xValue: (root.width-20)/2
    property real yValue: (root.height-10)/2

    Rectangle {
        id: bar1
        color: bcolor
        x: xValue
        y: yValue
        width: 20
        height: 2
        antialiasing: true
    }

    Rectangle {
        id: bar2
        color: "black"
        x: xValue
        y: yValue+5
        width: 20
        height: 2
        antialiasing: true
    }

    Rectangle {
        id: bar3
        color: "black"
        x: xValue
        y: yValue+10
        width: 20
        height: 2
        antialiasing: true
    }

    property int animationDuration: 500

    state: "menu"
    states: [
    State {
        name: "menu"
    },

    State {
        name: "back"
        PropertyChanges { target: root; rotation: 180 }
        PropertyChanges { target: bar1; rotation: 45; width: 13; x: xValue+7.5; y: yValue+3 }
        PropertyChanges { target: bar2; width: 17; x: xValue+1; y: yValue+7 }
        PropertyChanges { target: bar3; rotation: -45; width: 13; x: xValue+7.5; y: yValue+11 }
    }
    ]

    transitions: [
    Transition {
        RotationAnimation { target: root; direction: RotationAnimation.Clockwise; duration: animationDuration; easing.type: Easing.InOutQuad }
        PropertyAnimation { target: bar1; properties: "rotation, width, x, y"; duration: animationDuration; easing.type: Easing.InOutQuad }
        PropertyAnimation { target: bar2; properties: "rotation, width, x, y"; duration: animationDuration; easing.type: Easing.InOutQuad }
        PropertyAnimation { target: bar3; properties: "rotation, width, x, y"; duration: animationDuration; easing.type: Easing.InOutQuad }
    }
    ]
}

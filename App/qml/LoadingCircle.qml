import QtQuick 2.12

Item {
    id: loadingCircle
    width: 100
    height: 100
    visible: true

    Canvas {
        id: canvas
        anchors.fill: parent
        rotation: 0
        opacity: 1

        onPaint: {
            var ctx = canvas.getContext("2d");
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            ctx.beginPath();

            ctx.arc(canvas.width / 2, canvas.height / 2, 40,
                    (canvas.rotation / 360) * Math.PI * 2, (canvas.rotation / 360 + 0.75) * Math.PI * 2, false);

            ctx.strokeStyle = "#FF69B4";
            ctx.lineWidth = 5;
            ctx.stroke();
        }

        NumberAnimation {
            id: rotation
            target: canvas
            property: "rotation"
            from: 0
            to: 360
            duration: 1000
            loops: Animation.Infinite
            running: true
        }
    }
}

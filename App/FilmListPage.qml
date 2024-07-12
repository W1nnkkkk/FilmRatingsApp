import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.0
import com.melije.pulltorefresh 2.0

ColumnLayout {
    id: page1

    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        color: background.color
        ListView {
            id: listView
            model: filmModel
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10
            boundsMovement: ListView.StopAtBounds
            delegate: FilmListDelegate {
                id: filmDelegate
            }

            PullToRefreshHandler {
                id: pulldown_handler
                threshold: 20
                refreshIndicatorDelegate: RefreshIndicator {
                    id: ref
                }

                onPullDownRelease: {
                    requester.updateMovieModel()
                }
            }
        }
    }
}

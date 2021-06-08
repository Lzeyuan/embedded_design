import QtQuick 2.12
import QtQuick.Window 2.12
import QtMultimedia 5.14

import "qrc:/"

Window {
    width: 338
    height: 500
    visible: true
    title: qsTr("Tetris")
    minimumWidth: 338
    minimumHeight: 500


        GamePage {
            id: game
            anchors.fill: parent
            visible: true
        }

        MouseArea {
            width: 200
            height: 200
            onClicked: {

            }

        }



}

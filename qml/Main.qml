import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ApplicationWindow {
    id: window
    width: 800
    height: 800
    minimumWidth: 400
    minimumHeight: 400
    visible: true
    title: qsTr("Azimuth Degree Dial (0° - 360°)")

    background: Rectangle {
        color: "#070B14" // Deep dark aerospace slate
    }

    // Centered BIG Azimuth Dial filling the screen area
    Item {
        anchors.fill: parent
        anchors.margins: 20

        AzimuthDial {
            id: dial
            anchors.centerIn: parent
            width: Math.min(parent.width, parent.height)
            height: width

            // Automatically connected to networkReceiver backend
            azimuth: networkReceiver.azimuth
            targetAzimuth: networkReceiver.targetAzimuth
            showTargetBug: true
            interactive: true
        }
    }
}

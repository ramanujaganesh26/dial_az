import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ApplicationWindow {
    id: window
    width: 800
    height: 850
    minimumWidth: 400
    minimumHeight: 450
    visible: true
    title: qsTr("Azimuth Degree Dial (0° - 360°)")

    background: Rectangle {
        color: "#070B14" // Deep dark aerospace slate
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // 1. Centered BIG Azimuth Dial
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

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

        // 2. Small Angle Data Box Below Dial
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Math.min(220, window.width * 0.5)
            Layout.preferredHeight: 56
            radius: 10
            color: "#0F172A"
            border.color: "#00F0FF"
            border.width: 1.5

            RowLayout {
                anchors.centerIn: parent
                spacing: 10

                // Small Status Dot
                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: "#00F0FF"
                }

                // Angle Data Display
                ColumnLayout {
                    spacing: 0

                    Text {
                        text: "ANGLE DEGREE"
                        font.pixelSize: 9
                        font.bold: true
                        font.letterSpacing: 1.0
                        color: "#64748B"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: dial.formatDegree(dial.azimuth) + "  " + dial.getCardinalDirection(dial.azimuth)
                        font.pixelSize: 18
                        font.bold: true
                        font.family: "Monospace"
                        color: "#00F0FF"
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }
}

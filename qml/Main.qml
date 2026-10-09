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
    title: qsTr("0° - 360° Degree Dial Reader")

    background: Rectangle {
        color: "#070B14" // Deep aerospace slate dark
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        // 1. Centered BIG Dial Display
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

        // 2. Premium Angle Data Readout Box Below Dial
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Math.min(240, window.width * 0.6)
            Layout.preferredHeight: 64
            radius: 12
            color: "#0F172A"
            border.color: "#00F0FF"
            border.width: 1.5

            // Glassmorphic Gradient Overlay
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(0, 240, 255, 0.08) }
                    GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.35) }
                }
            }

            RowLayout {
                anchors.centerIn: parent
                spacing: 12

                // Live Indicator Pulse Dot
                Rectangle {
                    width: 10
                    height: 10
                    radius: 5
                    color: "#00F0FF"

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        PropertyAnimation { to: 0.3; duration: 600 }
                        PropertyAnimation { to: 1.0; duration: 600 }
                    }
                }

                // Data Readout Text
                ColumnLayout {
                    spacing: 1

                    Text {
                        text: "HEADING ANGLE"
                        font.pixelSize: 9
                        font.bold: true
                        font.letterSpacing: 1.2
                        color: "#64748B"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 8

                        Text {
                            text: dial.formatDegree(dial.azimuth)
                            font.pixelSize: 20
                            font.bold: true
                            font.family: "Monospace"
                            color: "#00F0FF"
                        }

                        Rectangle {
                            width: 1
                            height: 14
                            color: "#334155"
                        }

                        Text {
                            text: dial.getCardinalDirection(dial.azimuth)
                            font.pixelSize: 15
                            font.bold: true
                            color: "#F8FAFC"
                        }
                    }
                }
            }
        }
    }
}

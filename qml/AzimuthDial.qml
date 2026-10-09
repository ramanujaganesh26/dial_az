import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Item {
    id: root

    // --- Public Properties ---
    property real azimuth: 0.0          // 0 to 360 degrees reader value
    property real targetAzimuth: 45.0    // Secondary target bug degree
    property bool showTargetBug: true
    property bool interactive: true
    property bool showCenterHud: true
    property bool animateChanges: true

    // Visual Theme Colors
    property color accentColor: "#00F0FF"       // Neon Cyan primary needle
    property color targetColor: "#FF9E00"       // Neon Amber target bug
    property color dialBgColor: "#070C18"       // Deep dark aerospace navy
    property color dialRimColor: "#1E293B"      // Slate rim
    property color textColor: "#F8FAFC"         // Text color
    property color tickColor: "#334155"         // Minor ticks
    property color majorTickColor: "#94A3B8"    // Major ticks

    // Signals
    signal azimuthChangedByUser(real value)
    signal targetAzimuthChangedByUser(real value)

    implicitWidth: 350
    implicitHeight: 350

    // Ensure azimuth stays normalized in [0, 360) range
    onAzimuthChanged: {
        if (azimuth < 0) {
            azimuth = (azimuth % 360 + 360) % 360;
        } else if (azimuth >= 360) {
            azimuth = azimuth % 360;
        }
    }

    // Helper to format degree text
    function formatDegree(deg) {
        return deg.toFixed(1) + "°";
    }

    // Helper for 16-point cardinal direction string
    function getCardinalDirection(deg) {
        var normalized = (deg % 360 + 360) % 360;
        var directions = [
            "N", "NNE", "NE", "ENE",
            "E", "ESE", "SE", "SSE",
            "S", "SSW", "SW", "WSW",
            "W", "WNW", "NW", "NNW", "N"
        ];
        var index = Math.round(normalized / 22.5);
        return directions[index];
    }

    // Outer Glow Ring Shadow
    Rectangle {
        id: outerGlowRing
        anchors.fill: parent
        anchors.margins: Math.max(2, parent.width * 0.01)
        radius: width / 2
        color: "transparent"
        border.color: root.accentColor
        border.width: 1.5
        opacity: dialMouseArea.pressed ? 0.6 : 0.25

        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    // Main Dial Canvas for static ticks, numbers, & grid
    Canvas {
        id: dialCanvas
        anchors.fill: parent
        anchors.margins: Math.max(4, parent.width * 0.02)
        antialiasing: true

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            var w = width;
            var h = height;
            var cx = w / 2;
            var cy = h / 2;
            var outerRadius = Math.min(cx, cy) - 2;

            var isCompact = (outerRadius < 90);
            var tickScale = outerRadius / 150.0;
            var innerRadius = outerRadius - Math.max(12, 28 * tickScale);

            // 1. Premium Metallic Background Disk Gradient
            var bgGrad = ctx.createRadialGradient(cx, cy, 5, cx, cy, outerRadius);
            bgGrad.addColorStop(0, "#0F172A");
            bgGrad.addColorStop(0.65, root.dialBgColor);
            bgGrad.addColorStop(1, "#030712");

            ctx.beginPath();
            ctx.arc(cx, cy, outerRadius, 0, 2 * Math.PI, false);
            ctx.fillStyle = bgGrad;
            ctx.fill();

            // 2. Bezel Rim (Dual Ring)
            ctx.lineWidth = Math.max(2.5, 4.5 * tickScale);
            ctx.strokeStyle = root.dialRimColor;
            ctx.stroke();

            ctx.lineWidth = 1;
            ctx.strokeStyle = Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.4);
            ctx.stroke();

            // 3. Concentric Radar Grid Rings & Crosshair
            ctx.strokeStyle = Qt.rgba(0.2, 0.35, 0.5, 0.25);
            ctx.lineWidth = 1;
            var stepR = (innerRadius - Math.max(15, 40 * tickScale)) / 3;
            for (var r = 1; r <= 3; r++) {
                ctx.beginPath();
                ctx.arc(cx, cy, Math.max(15, 40 * tickScale) + r * stepR, 0, 2 * Math.PI, false);
                ctx.stroke();
            }

            // Crosshair lines
            ctx.beginPath();
            ctx.moveTo(cx - outerRadius + Math.max(10, 35 * tickScale), cy);
            ctx.lineTo(cx + outerRadius - Math.max(10, 35 * tickScale), cy);
            ctx.moveTo(cx, cy - outerRadius + Math.max(10, 35 * tickScale));
            ctx.lineTo(cx, cy + outerRadius - Math.max(10, 35 * tickScale));
            ctx.strokeStyle = Qt.rgba(0.2, 0.35, 0.5, 0.2);
            ctx.stroke();

            // 4. Tick Marks & Numbers (0 to 360 degrees)
            ctx.save();
            ctx.translate(cx, cy);

            var tickStep = isCompact ? 10 : 2;

            for (var deg = 0; deg < 360; deg += tickStep) {
                var rad = (deg - 90) * Math.PI / 180;
                var isCardinal = (deg % 90 === 0);
                var isMajor = (deg % 30 === 0);
                var isMedium = (deg % 10 === 0 && !isMajor);

                var tickLen = isCardinal ? Math.max(9, 18 * tickScale) :
                              (isMajor ? Math.max(7, 14 * tickScale) :
                              (isMedium ? Math.max(4, 9 * tickScale) : Math.max(3, 5 * tickScale)));

                var r1 = outerRadius - 2;
                var r2 = r1 - tickLen;

                var x1 = r1 * Math.cos(rad);
                var y1 = r1 * Math.sin(rad);
                var x2 = r2 * Math.cos(rad);
                var y2 = r2 * Math.sin(rad);

                ctx.beginPath();
                ctx.moveTo(x1, y1);
                ctx.lineTo(x2, y2);

                if (isCardinal) {
                    ctx.lineWidth = Math.max(2.5, 4 * tickScale);
                    if (deg === 0) ctx.strokeStyle = "#FF4B4B";       // North Red
                    else if (deg === 90) ctx.strokeStyle = "#00F0FF";  // East Cyan
                    else if (deg === 180) ctx.strokeStyle = "#10B981"; // South Emerald
                    else if (deg === 270) ctx.strokeStyle = "#FF9E00"; // West Amber
                } else if (isMajor) {
                    ctx.lineWidth = Math.max(1.5, 2.5 * tickScale);
                    ctx.strokeStyle = root.majorTickColor;
                } else if (isMedium) {
                    ctx.lineWidth = 1;
                    ctx.strokeStyle = root.majorTickColor;
                } else {
                    ctx.lineWidth = 1;
                    ctx.strokeStyle = root.tickColor;
                }
                ctx.stroke();

                // Numbers & Labels for every 30 degrees (Highlighting 4 Major Directions)
                if (isMajor) {
                    var labelR = r2 - (isCardinal ? Math.max(10, 16 * tickScale) : Math.max(8, 12 * tickScale));
                    var lx = labelR * Math.cos(rad);
                    var ly = labelR * Math.sin(rad);

                    ctx.save();
                    ctx.translate(lx, ly);

                    var labelText = deg.toString();
                    if (deg === 0) labelText = isCompact ? "N 0°" : "N (0°)";
                    else if (deg === 90) labelText = isCompact ? "E 90°" : "E (90°)";
                    else if (deg === 180) labelText = isCompact ? "S 180°" : "S (180°)";
                    else if (deg === 270) labelText = isCompact ? "W 270°" : "W (270°)";

                    var showThisText = !isCompact || isCardinal;

                    if (showThisText) {
                        var fontPx = isCardinal ? Math.max(9, Math.min(13, Math.round(11.5 * tickScale))) :
                                                  Math.max(7, Math.min(10, Math.round(9 * tickScale)));
                        ctx.font = isCardinal ? "bold " + fontPx + "px sans-serif" : fontPx + "px sans-serif";
                        ctx.textAlign = "center";
                        ctx.textBaseline = "middle";

                        if (deg === 0) {
                            ctx.fillStyle = "#FF4B4B"; // North Red
                        } else if (deg === 90) {
                            ctx.fillStyle = "#00F0FF"; // East Cyan
                        } else if (deg === 180) {
                            ctx.fillStyle = "#10B981"; // South Emerald
                        } else if (deg === 270) {
                            ctx.fillStyle = "#FF9E00"; // West Amber
                        } else {
                            ctx.fillStyle = root.textColor;
                        }

                        ctx.fillText(labelText, 0, 0);
                    }
                    ctx.restore();
                }
            }

            // 5. Major 4 Direction Outer Notch Indicators (N 0°, E 90°, S 180°, W 270°)
            var cardinalPoints = [
                { deg: 0,   color: "#FF4B4B" },
                { deg: 90,  color: "#00F0FF" },
                { deg: 180, color: "#10B981" },
                { deg: 270, color: "#FF9E00" }
            ];

            var notchW = Math.max(3.5, 5.5 * tickScale);
            var notchH = Math.max(4.5, 7.5 * tickScale);

            for (var c = 0; c < cardinalPoints.length; c++) {
                var cp = cardinalPoints[c];
                var crad = (cp.deg - 90) * Math.PI / 180;

                ctx.save();
                ctx.translate(outerRadius * Math.cos(crad), outerRadius * Math.sin(crad));
                ctx.rotate(crad + Math.PI / 2);

                ctx.beginPath();
                ctx.moveTo(0, 0);
                ctx.lineTo(-notchW, -notchH);
                ctx.lineTo(notchW, -notchH);
                ctx.closePath();
                ctx.fillStyle = cp.color;
                ctx.fill();

                ctx.restore();
            }

            ctx.restore();
        }
    }

    // --- Layer 2: Target Bearing Bug Marker ---
    Item {
        id: targetBugContainer
        anchors.fill: dialCanvas
        visible: root.showTargetBug

        rotation: root.targetAzimuth

        Behavior on rotation {
            enabled: root.animateChanges
            NumberAnimation { duration: 250; easing.type: Easing.OutQuad }
        }

        Canvas {
            anchors.fill: parent
            antialiasing: true
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                var cx = width / 2;
                var cy = height / 2;
                var r = Math.min(cx, cy) - 10;
                var scale = r / 150.0;

                var bw = Math.max(4, 6 * scale);
                var bh = Math.max(6, 10 * scale);

                ctx.fillStyle = root.targetColor;
                ctx.beginPath();
                ctx.moveTo(cx, cy - r);
                ctx.lineTo(cx - bw, cy - r - bh);
                ctx.lineTo(cx + bw, cy - r - bh);
                ctx.closePath();
                ctx.fill();

                ctx.strokeStyle = "#FFFFFF";
                ctx.lineWidth = 1;
                ctx.beginPath();
                ctx.moveTo(cx, cy - r + 1);
                ctx.lineTo(cx, cy - r - bh + 1);
                ctx.stroke();
            }
        }
    }

    // --- Layer 3: Rotating Pointer / Laser Needle ---
    Item {
        id: needleContainer
        anchors.fill: dialCanvas

        rotation: root.azimuth

        Behavior on rotation {
            enabled: root.animateChanges && !dialMouseArea.pressed
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        Canvas {
            id: needleCanvas
            anchors.fill: parent
            antialiasing: true

            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                var cx = width / 2;
                var cy = height / 2;
                var outerR = Math.min(cx, cy) - 14;
                var scale = outerR / 150.0;

                var pointerTipY = cy - outerR + Math.max(10, 18 * scale);
                var tailY = cy + Math.max(12, 24 * scale);
                var nw = Math.max(3, 5 * scale);

                // Needle Body Laser Gradient Pointer
                var grad = ctx.createLinearGradient(cx, pointerTipY, cx, cy);
                grad.addColorStop(0, root.accentColor);
                grad.addColorStop(1, Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.15));

                ctx.beginPath();
                ctx.moveTo(cx, pointerTipY);
                ctx.lineTo(cx - nw, cy - 15 * scale);
                ctx.lineTo(cx - (nw * 0.5), tailY);
                ctx.lineTo(cx + (nw * 0.5), tailY);
                ctx.lineTo(cx + nw, cy - 15 * scale);
                ctx.closePath();
                ctx.fillStyle = grad;
                ctx.fill();

                // Illuminated center line
                ctx.strokeStyle = "#FFFFFF";
                ctx.lineWidth = Math.max(1, 1.5 * scale);
                ctx.beginPath();
                ctx.moveTo(cx, pointerTipY + 2);
                ctx.lineTo(cx, cy - 8);
                ctx.stroke();

                // Tail counterweight
                ctx.fillStyle = Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.6);
                ctx.beginPath();
                ctx.moveTo(cx, tailY + Math.max(5, 8 * scale));
                ctx.lineTo(cx - nw, tailY);
                ctx.lineTo(cx + nw, tailY);
                ctx.closePath();
                ctx.fill();
            }
        }
    }

    // --- Layer 4: HUD Digital Center Readout Cap (WITHOUT "AZIMUTH" text) ---
    Rectangle {
        id: centerHud
        visible: root.showCenterHud
        width: Math.min(parent.width, parent.height) * 0.40
        height: width
        anchors.centerIn: parent
        radius: width / 2
        color: "#0B1120"
        border.color: dialMouseArea.pressed ? root.accentColor : "#334155"
        border.width: Math.max(1.5, width * 0.035)

        // Glassmorphic Overlay Gradient
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.09) }
                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.45) }
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 2

            // Large Digital Numerical Readout (Word "AZIMUTH" removed!)
            Text {
                id: degreeText
                text: root.formatDegree(root.azimuth)
                font.pixelSize: Math.max(12, Math.min(22, parent.parent.width * 0.32))
                font.bold: true
                font.family: "Monospace"
                color: root.accentColor
                Layout.alignment: Qt.AlignHCenter
            }

            // Cardinal Direction Tag
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 4

                Rectangle {
                    width: Math.max(4, parent.parent.parent.width * 0.07)
                    height: width
                    radius: width / 2
                    color: root.accentColor
                }

                Text {
                    text: root.getCardinalDirection(root.azimuth)
                    font.pixelSize: Math.max(9, Math.min(13, parent.parent.parent.width * 0.18))
                    font.bold: true
                    color: root.textColor
                }
            }
        }
    }

    // --- Interactive Mouse/Touch Drag Area ---
    MouseArea {
        id: dialMouseArea
        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

        function updateAngle(mx, my) {
            var cx = width / 2;
            var cy = height / 2;
            var dx = mx - cx;
            var dy = my - cy;

            var rad = Math.atan2(dy, dx);
            var deg = rad * (180 / Math.PI) + 90;
            if (deg < 0) deg += 360;
            deg = deg % 360;

            root.azimuth = deg;
            root.azimuthChangedByUser(deg);
        }

        onPressed: (mouse) => updateAngle(mouse.x, mouse.y)
        onPositionChanged: (mouse) => {
            if (pressed) {
                updateAngle(mouse.x, mouse.y);
            }
        }
    }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services
import qs.Widgets

Item {
    id: root

    readonly property int coverSize: Math.min(32, Style.barHeight - Style.margin2XS)
    readonly property int maxLength: 30
    readonly property string title: {
        var artist = MediaService.trackArtist;
        var track = MediaService.trackTitle;
        var o = (artist ? `${artist} - ${track}` : track);
        if (o.length > maxLength)
            return o.substring(0, maxLength).trim() + "...";

        return o;
    }

    implicitHeight: coverSize
    implicitWidth: row_layout.implicitWidth + row_layout.spacing

    Rectangle {
        anchors.fill: root
        color: mouse.hovered ? Qt.alpha(Colors.md3.primary, 0.5) : "transparent"
        radius: Style.radiusS
        anchors.margins: -Style.marginXXS

        Behavior on color {
            ColorAnimation {
                duration: Style.animationFast
            }

        }

    }

    RowLayout {
        id: row_layout

        anchors.fill: root

        NImageRounded {
            id: cover

            width: coverSize
            height: coverSize
            radius: Style.radiusM
            source: MediaService.trackArtUrl
            sourceWidth: coverSize
            sourceHeight: coverSize
        }

        NText {
            id: label

            height: coverSize
            text: title
            Layout.fillHeight: true
            verticalAlignment: Text.AlignVCenter
        }

        NIcon {
            id: playing

            height: coverSize
            verticalAlignment: Text.AlignVCenter
            text: MediaService.isPlaying ? "" : ""
            size: Style.fontSizeXL
            Layout.minimumWidth: font.pixelSize / 4 * 3
            Layout.fillHeight: true
        }

    }

    MouseArea {
        property int wheelAccumulator: 0

        anchors.fill: row_layout
        onClicked: function(event) {
            MediaService.playPause();
        }
        onWheel: function(wheel) {
            var delta = wheel.angleDelta.y;
            wheelAccumulator += delta;
            if (wheelAccumulator >= 120) {
                wheelAccumulator = 0;
                MediaService.increaseVolume();
            } else if (wheelAccumulator <= -120) {
                wheelAccumulator = 0;
                MediaService.decreaseVolume();
            }
        }
    }

    TapHandler {
        acceptedButtons: Qt.BackButton | Qt.ForwardButton
        onTapped: function(eventPoint, button) {
            if (button === Qt.BackButton)
                MediaService.previous();
            else if (button === Qt.ForwardButton)
                MediaService.next();
        }
    }

    HoverHandler {
        id: mouse

        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    }

}

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services

Item {
    id: root

    readonly property int coverSize: 30
    readonly property int maxLength: 30
    readonly property string title: {
        var artist = MediaService.trackArtist;
        var track = MediaService.trackTitle;
        var o = (artist ? `${artist} - ${track}` : track);
        if (o.length > maxLength)
            return o.substring(0, maxLength).trim() + "...";

        return o;
    }

    implicitHeight: row_layout.implicitHeight
    implicitWidth: row_layout.implicitWidth + row_layout.spacing

    Rectangle {
        anchors.fill: root
        color: mouse.hovered ? Colors.a(Colors.md3.primary, 0.5) : "transparent"
        radius: 2

        Behavior on color {
            ColorAnimation {
                duration: 150
            }

        }

    }

    RowLayout {
        id: row_layout

        Image {
            id: cover

            source: MediaService.trackArtUrl

            sourceSize {
                width: coverSize
                height: coverSize
            }

        }

        Text {
            id: label

            Layout.alignment: Qt.AlignVCenter
            text: title
        }

        Text {
            id: playing

            Layout.alignment: Qt.AlignVCenter
            text: MediaService.isPlaying ? "" : ""
            font.pixelSize: 16
            Layout.minimumWidth: font.pixelSize / 4 * 3
        }

    }

    MouseArea {
        property int wheelAccumulator: 0

        anchors.fill: row_layout
        onClicked: {
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

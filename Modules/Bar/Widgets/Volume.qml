import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.Commons
import qs.Services

Item {
    implicitWidth: root.width
    Layout.fillHeight: true

    BarGroup {
        id: root

        readonly property var sink: Pipewire.defaultAudioSink
        readonly property bool ready: sink && sink.ready
        readonly property bool muted: ready && sink.audio.muted
        readonly property int vol: ready ? Math.round(sink.audio.volume * 100) : 0
        readonly property string icon: {
            if (!ready)
                return String.fromCodePoint(984449);

            if (muted)
                return String.fromCodePoint(986632);

            if (vol === 0)
                return String.fromCodePoint(984449);

            if (vol < 34)
                return String.fromCodePoint(984447);

            if (vol < 67)
                return String.fromCodePoint(984448);

            return String.fromCodePoint(984446);
        }

        anchors.fill: parent

        Text {
            text: root.icon
            color: root.ready ? Colors.md3.on_background : Colors.status_err

            font {
                pixelSize: 20
            }

        }

        Text {
            text: {
                if (!root.ready)
                    return "-";

                return root.vol + "%";
            }
            color: root.muted ? Colors.status_err : Colors.md3.on_background
        }

        Item {
            visible: false

            PwObjectTracker {
                id: sinkTracker

                objects: [root.sink]
            }

        }

    }

    MouseArea {
        property int wheelAccumulator: 0

        onWheel: function(wheel) {
            var delta = wheel.angleDelta.y;
            wheelAccumulator += delta;
            if (wheelAccumulator >= 120) {
                wheelAccumulator = 0;
                AudioService.increaseVolume();
            } else if (wheelAccumulator <= -120) {
                wheelAccumulator = 0;
                AudioService.decreaseVolume();
            }
        }
        anchors.fill: parent
    }

}

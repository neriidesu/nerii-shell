import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Services

Item {

    implicitWidth: Math.max(100, text.contentWidth)
    implicitHeight: Style.barHeight
    Text {
        id: text
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        readonly property int maxLength: 60
        readonly property string title: {
            var text = Hyprland.activeToplevel ? Hyprland.activeToplevel.title : "nerii-shell";
            if (text?.length > maxLength)
                return text.substring(0, maxLength).trim() + "...";

            return text;
        }

        text: title

        font {
            letterSpacing: 1
            weight: Style.fontWeightLight
        }

    }

}

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Services

Item {

    implicitWidth: text.implicitWidth
    implicitHeight: Style.barHeight
    Text {
        id: text

        anchors.verticalCenter: parent.verticalCenter

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

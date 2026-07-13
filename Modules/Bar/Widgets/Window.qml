import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Commons

Text {
    readonly property int maxLength: 60
    readonly property string title: {
        var text = Hyprland.activeToplevel?.title
        if (text.length > maxLength) {
            return text.substring(0, maxLength) + "..."
        }

        return text
    }

    text: title

    font {
        letterSpacing: 1
        weight: 200
    }

}

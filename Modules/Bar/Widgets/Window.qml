import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Commons

Text {
    text: "[ " + Hyprland.activeToplevel?.title + " ]"
    color: Colors.md3.on_background

    font {
        family: Fonts.code
        letterSpacing: 1
        pixelSize: 12
        weight: 200
    }

}

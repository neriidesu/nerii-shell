import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Commons

Text {
    text: Hyprland.activeToplevel?.title

    font {
        letterSpacing: 1
        weight: 200
    }

}

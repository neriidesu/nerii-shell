import QtQuick
import Quickshell
import qs.Commons
import qs.Widgets

NText {
    text: "󰅐 " + Time.time
    size: Style.fontSizeL

    font {
        family: Fonts.code
        letterSpacing: 2
    }

}

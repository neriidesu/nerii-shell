import QtQuick
import Quickshell
import qs.Commons

Text {
    property real size: Style.fontSizeM

    color: Colors.md3.on_background

    font {
        family: Fonts.code
        pixelSize: size
    }

}

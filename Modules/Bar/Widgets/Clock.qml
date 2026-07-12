import QtQuick
import Quickshell
import qs.Commons

Text {
    text: Time.time
    color: Colors.md3.on_background

    font {
        family: Fonts.code
        letterSpacing: 2
        pixelSize: 12
        weight: 400
    }

}

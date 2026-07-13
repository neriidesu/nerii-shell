import QtQuick
import Quickshell
import qs.Commons

Text {
    //type:  -1 '[' 0 '|' 1 ']'

    property var type

    text: {
        switch (type) {
        case -1:
            '[';
            break;
        case 0:
            '|';
            break;
        case 1:
            ']';
            break;
        default:
            '|';
            break;
        }
    }
    font.pixelSize: 14
    color: Colors.md3.primary
}

import QtQuick
import Quickshell
import qs.Commons
import qs.Widgets

NText {
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
    size: Style.fontSizeL
    color: Colors.md3.primary
}

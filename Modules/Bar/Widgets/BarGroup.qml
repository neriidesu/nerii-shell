import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons

Item {
    id: root

    property real padding: Style.marginL
    property real spacing: Style.marginS
    default property alias items: rowLayout.children

    implicitWidth: rowLayout.implicitWidth + padding * 2
    Layout.fillHeight: true
    clip: true

    Rectangle {
        id: background

        visible: Style.barIsSeparate
        color: Style.cDefaultBackground
        radius: 0

        border {
            color: Colors.md3.primary
            width: Style.borderM
        }

        anchors {
            fill: parent
            margins: 0
        }

    }

    RowLayout {
        id: rowLayout

        spacing: root.spacing

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
            margins: root.padding
        }

    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Style.animationFast
            easing.type: Easing.InOutCubic
        }

    }

}

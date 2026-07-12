import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons

Item {
    id: root

    property real padding: 12
    default property alias items: rowLayout.children

    implicitWidth: rowLayout.implicitWidth + padding * 2
    Layout.fillHeight: true

    Rectangle {
        id: background

        color: Colors.md3.surface_container
        radius: 5

        anchors {
            fill: parent
            margins: 4
        }

    }

    RowLayout {
        id: rowLayout

        spacing: 12

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
            margins: root.padding
        }

    }

}

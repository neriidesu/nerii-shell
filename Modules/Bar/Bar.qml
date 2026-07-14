// TODO: Implement noctalia panel service on tray
// TODO: Start menu
// TODO: Media panel
// TODO: Weather panel

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Modules.Bar.Widgets

PanelWindow {
    id: bar_root

    readonly property real edgeMargin: 10

    implicitHeight: 40 + edgeMargin
    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
    }

    LeftModules {
        anchors {
            left: parent.left
            bottom: parent.bottom
            top: parent.top
            leftMargin: bar_root.edgeMargin
            topMargin: bar_root.edgeMargin
            rightMargin: bar_root.edgeMargin
        }

    }

    CenterModules {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            top: parent.top
            leftMargin: bar_root.edgeMargin
            topMargin: bar_root.edgeMargin
            rightMargin: bar_root.edgeMargin
        }

    }

    RightModules {
        anchors {
            right: parent.right
            bottom: parent.bottom
            top: parent.top
            leftMargin: bar_root.edgeMargin
            topMargin: bar_root.edgeMargin
            rightMargin: bar_root.edgeMargin
        }

    }

}

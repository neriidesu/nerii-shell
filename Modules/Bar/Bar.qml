// TODO: Spotify integration
// TODO: Weather widget
// TODO: Animations
// TODO: Start menu

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Modules.Bar.Widgets

PanelWindow {
    id: root

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
            leftMargin: root.edgeMargin
            topMargin: root.edgeMargin
            rightMargin: root.edgeMargin
        }

    }

    CenterModules {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            top: parent.top
            leftMargin: root.edgeMargin
            topMargin: root.edgeMargin
            rightMargin: root.edgeMargin
        }

    }

    RightModules {
        anchors {
            right: parent.right
            bottom: parent.bottom
            top: parent.top
            leftMargin: root.edgeMargin
            topMargin: root.edgeMargin
            rightMargin: root.edgeMargin
        }

    }

}

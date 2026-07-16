import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Modules.Bar.Widgets

Item {
    id: bar_root

    property ShellScreen screen: null

    anchors.fill: parent

    LeftModules {
        anchors {
            left: parent.left
            bottom: parent.bottom
            top: parent.top
        }

    }

    CenterModules {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            top: parent.top
        }

    }

    RightModules {
        anchors {
            right: parent.right
            bottom: parent.bottom
            top: parent.top
        }

    }

}

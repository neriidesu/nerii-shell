import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Modules.Bar.Widgets

PanelWindow {
    implicitHeight: 30
    color: Colors.md3.background

    anchors {
        top: true
        left: true
        right: true
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14

        Workspaces {
        }

        Item {
            Layout.fillWidth: true
        }

        Window {
        }

        Item {
            Layout.fillWidth: true
        }

        Clock {
        }

    }

}

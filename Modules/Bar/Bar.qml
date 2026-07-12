import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Modules.Bar.Widgets

PanelWindow {
    implicitHeight: 32
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

        BarGroup {
            Workspaces {
            }

        }

        Item {
            Layout.fillWidth: true
        }

        Window {
        }

        Item {
            Layout.fillWidth: true
        }

        Volume {
        }

        Battery {
            visible: Config.showBattery
        }

        Clock {
        }

    }

}

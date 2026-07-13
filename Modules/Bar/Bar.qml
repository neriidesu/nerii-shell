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
        spacing: 4

        RowLayout {
            id: left_modules

            BarGroup {
                Workspaces {
                }

            }

        }

        Item {
            Layout.fillWidth: true
        }

        RowLayout {
            id: right_modules

            Volume {
            }

            Network {
            }

            Battery {
                visible: Config.showBattery
            }

            Clock {
            }

        }

    }

}

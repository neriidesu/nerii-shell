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

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: root.edgeMargin
        anchors.topMargin: root.edgeMargin
        anchors.rightMargin: root.edgeMargin
        spacing: 4

        RowLayout {
            id: left_modules

            BarGroup {
                Separator {
                    type: -1
                }

                Workspaces {
                }

                Separator {
                    type: 1
                }

            }

        }

        Item {
            Layout.fillWidth: true
        }

        RowLayout {
            id: right_modules

            BarGroup {
                Separator {
                    type: -1
                }

                Volume {
                }

                Separator {
                }

                Network {
                }

                Separator {
                }

                Battery {
                    visible: Config.showBattery
                }

                Separator {
                    visible: Config.showBattery
                }

                Clock {
                }

                Separator {
                    type: 1
                }

            }

        }

    }

}

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Modules.Core
import qs.Services
import qs.Widgets

SmartPanel {
    id: root

    panelContent: Item {
        id: panelContent

        readonly property real contentPreferredWidth: 500
        readonly property real contentPreferredHeight: 100 + Style.marginM

        anchors.fill: parent

        Rectangle {
            id: content

            color: root.panelBackgroundColor
            width: parent.width
            height: parent.height
            radius: Style.radiusM
            topLeftRadius: root.isConnected ? 0 : undefined
            topRightRadius: root.isConnected ? 0 : undefined

            border {
                color: root.panelBorderColor
                width: root.showBorders ? Style.borderM : 0
            }

            RowLayout {
                id: layout

                anchors.margins: Style.marginM
                anchors.fill: parent
                spacing: Style.marginM

                NButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    label: "Lock"
                    showIcon: true
                    icon: "󰌾"
                    hoverColor: Colors.grey_0
                    onClicked: {
                        closeImmediately();
                        CompositorService.lock();
                    }
                }

                NButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    label: "Log Out"
                    showIcon: true
                    icon: "󰍃"
                    hoverColor: Colors.purple
                    onClicked: {
                        closeImmediately();
                        CompositorService.logout();
                    }
                }

                NButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    label: "Sleep"
                    showIcon: true
                    icon: "󰤄"
                    hoverColor: Colors.blue
                    onClicked: {
                        closeImmediately();
                        CompositorService.hibernate();
                    }
                }

                NButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    label: "Reboot"
                    showIcon: true
                    icon: "󰜉"
                    hoverColor: Colors.yellow
                    onClicked: {
                        closeImmediately();
                        CompositorService.reboot();
                    }
                }

                NButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    label: "Shutdown"
                    showIcon: true
                    icon: "󰐥"
                    hoverColor: Colors.status_err
                    onClicked: {
                        closeImmediately();
                        CompositorService.shutdown();
                    }
                }

            }

        }

    }

}

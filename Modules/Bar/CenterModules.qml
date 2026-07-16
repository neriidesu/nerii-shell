import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Modules.Bar.Widgets
import qs.Services

Item {
    id: root
    property bool isHovered: false

    width: center_modules.implicitWidth
    RowLayout {
        anchors.fill: parent
        id: center_modules

        BarGroup {
            id: normal_group
            visible: !root.isHovered && !PanelService.getPanel("sessionMenuPanel", screen).isPanelOpen
            Separator {
                type: -1
            }

            Window {
            }

            Separator {
                type: 1
            }

        }

        BarGroup {
            visible: root.isHovered || PanelService.getPanel("sessionMenuPanel", screen).isPanelOpen
            Layout.preferredWidth: normal_group.width
            Separator {
                type: -1
            }

            Text {
                horizontalAlignment: Text.AlignHCenter
                text: "Session Menu"
                Layout.fillWidth: true
            }

            Separator {
                type: 1
            }
        }

    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            PanelService.getPanel("sessionMenuPanel", screen)?.toggle(parent);
        }

        onEntered: {
            root.isHovered = true;
        }
        onExited: {
            root.isHovered = false;
        }
    }

}

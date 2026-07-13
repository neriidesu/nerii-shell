import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Commons

RowLayout {
    function getWorkspaceText(index) {
        var text = "undefined";
        switch (index + 1) {
        case 3:
            text = "";
            break;
        case 4:
            text = "";
            break;
        case 10:
            text = "󰍜";
            break;
        default:
            text = index + 1;
            break;
        }
        return text;
    }

    spacing: 5

    Repeater {
        id: repeater

        model: 10

        Text {
            property var ws: Hyprland.workspaces.values.find((w) => {
                return w.id === index + 1;
            })
            property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
            property bool keep: {
            if (Config.keepWorkspaces.includes(index + 1)) {
                true;
            } else {
                false;
            }}

            text: getWorkspaceText(index)
            color: isActive ? Colors.md3.primary : (ws ? Colors.md3.on_background : Colors.md3.surface_container_highest)
            visible: ws ? true : keep

            font {
                family: Fonts.code
                weight: 600
                pixelSize: 14
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }

            }

        }

    }

}

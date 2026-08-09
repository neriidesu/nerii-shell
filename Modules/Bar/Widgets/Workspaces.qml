import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Commons
import qs.Widgets

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

    spacing: Style.marginM

    Repeater {
        id: repeater

        model: 10

        NText {
            property var ws: Hyprland.workspaces.values.find((w) => {
                return w.id === index + 1;
            })
            property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
            property bool onScreen: {
                if (bar_root.screen.name == ws?.monitor?.name)
                    true;
                else
                    false;
            }
            property bool keep: {
                if (Config.data.bar.keepWorkspaces == null) {
                    return false
                }
                if (Object.keys(Config.data.bar.keepWorkspaces).includes(bar_root.screen.name)) {
                    if (Config.data.bar.keepWorkspaces[bar_root.screen.name].includes(index + 1))
                    true;
                    else
                    false;
                }


                
            }

            text: getWorkspaceText(index)
            color: isActive ? Colors.md3.primary : (ws ? Colors.md3.on_background : Colors.md3.surface_container_highest)
            visible: ws ? onScreen : keep 

            font {
                family: Fonts.code
                weight: Style.fontWeightSemiBold
            }
                size: Style.fontSizeL

            Behavior on color {
                ColorAnimation {
                    duration: Style.animationFast
                }

            }

        }

    }

}

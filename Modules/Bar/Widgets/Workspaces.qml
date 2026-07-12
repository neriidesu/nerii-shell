import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Commons

RowLayout {
    function getWorkspaceText(index) {
        var text = index + 1;
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
        }
        return text;
    }

    spacing: 7

    Repeater {
        id: repeater

        model: 10

        Text {
            property bool isActive: Hyprland.focusedWorkspace.id === (index + 1)

            text: getWorkspaceText(index)
            color: isActive ? Colors.md3.primary : Colors.md3.on_background

            font {
                family: Fonts.code
                weight: isActive ? 900 : 400
                pixelSize: isActive ? 14 : 12
            }

        }

    }

}

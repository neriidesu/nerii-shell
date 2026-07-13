import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs.Commons

RowLayout {
    readonly property var trayItems: SystemTray.items.values
    readonly property int iconSize: 16

    spacing: 5

    Repeater {
        id: repeater

        model: SystemTray.items && SystemTray.items.values ? SystemTray.items.values : []

        Image {
            source: trayItems[index].icon
            visible: {
                if (Config.blacklistTrayIds.includes(trayItems[index].id))
                    false;
                else
                    true;
            }

            sourceSize {
                width: iconSize
                height: iconSize
            }

        }

    }

}

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs.Commons

RowLayout {
    id: root

    readonly property var trayItems: SystemTray.items.values
    readonly property int iconSize: 16

    spacing: 5

    Repeater {
        id: repeater

        model: SystemTray.items && SystemTray.items.values ? SystemTray.items.values : []

        Image {
            source: modelData.icon
            visible: {
                !Config.blacklistTrayIds.includes(modelData.id);
            }

            sourceSize {
                width: iconSize
                height: iconSize
            }

        }

    }

}

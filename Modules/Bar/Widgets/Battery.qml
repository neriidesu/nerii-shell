import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs.Commons
import qs.Widgets

BarGroup {
    id: root

    property var battery: UPower.displayDevice
    property bool charging: battery.state === UPowerDeviceState.Charging
    readonly property int level: Math.round(battery.percentage * 100)
    readonly property string icon: {
        if (charging)
            return String.fromCodePoint(983172);

        if (level >= 100)
            return String.fromCodePoint(983161);

        if (level < 10)
            return String.fromCodePoint(983171);

        return String.fromCodePoint(983162 + (Math.floor(level / 10) - 1));
    }

    NIcon {
        text: root.icon
        color: root.charging ? Colors.yellow : root.level <= 15 ? Colors.status_err : root.level <= 30 ? Colors.status_pending : Colors.status_ok
        size: Style.fontSizeXXL
    }

    NText {
        text: root.level + "%"
        size: Style.fontSizeL

        font {
            family: Style.fontJp
            letterSpacing: 2
        }

    }

}

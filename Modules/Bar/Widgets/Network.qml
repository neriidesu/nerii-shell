import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import qs.Commons

BarGroup {
    id: root

    RowLayout {
        id: wifi

        property var wifiDevice: Networking.devices.values.find((d) => {
            return d.type === DeviceType.Wifi;
        })
        property var active: wifi.wifiDevice ? wifiDevice.networks.values.find((n) => {
            return n.connected;
        }) : null
        readonly property real signal: wifi.active ? wifi.active.signalStrength : 0
        readonly property string icon: {
            if (!Networking.wifiEnabled)
                return String.fromCodePoint(984490);

            if (!active)
                return String.fromCodePoint(985389);

            let tier = wifi.signal >= 0.75 ? 4 : wifi.signal >= 0.5 ? 3 : wifi.signal >= 0.25 ? 2 : 1;
            return String.fromCodePoint(985375 + (tier - 1) * 3);
        }

        visible: Config.showWifi
        implicitHeight: wifi_icon.implicitHeight
        implicitWidth: wifi_icon.implicitWidth + wifi_label.implicitWidth

        Text {
            id: wifi_icon

            text: wifi.icon
            color: Networking.wifiEnabled ? Colors.purple : Colors.grey_0
            font.pixelSize: 14
        }

        Text {
            id: wifi_label

            text: {
                if (!Networking.wifiEnabled)
                    return "off";

                if (!wifi.active)
                    return "Disconnected";

                return wifi.active.name;
            }
        }

    }

    RowLayout {
        id: eth

        property var wifiDevice: Networking.devices.values.find((d) => {
            return d.type === DeviceType.Wired;
        })
        property var active: eth.wifiDevice ? eth.wifiDevice.connected : null
        readonly property string icon: {
            if (!active)
                return String.fromCodePoint(986268);

            return String.fromCodePoint(986269);
        }

        visible: Config.showEth
        implicitHeight: eth_icon.implicitHeight
        implicitWidth: eth_icon.implicitWidth + eth_label.implicitWidth

        Text {
            id: eth_icon

            text: eth.icon
            color: Networking.wifiEnabled ? Colors.purple : Colors.grey_0
            font.pixelSize: 14
        }

        Text {
            id: eth_label

            text: eth.wifiDevice.name
        }

    }

}

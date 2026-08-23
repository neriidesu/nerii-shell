import QtQuick
import Quickshell
import qs.Commons
import qs.Services
import qs.Widgets

Item {
    id: root

    readonly property bool weatherReady: Config.data.weather.updateWeather && (LocationService.data.weather !== null)

    implicitHeight: row.height
    implicitWidth: row.width

    Rectangle {
        anchors.fill: root
        color: mouse.hovered ? Qt.alpha(Colors.md3.primary, 0.5) : "transparent"
        radius: Style.radiusS
        anchors.margins: -Style.marginXS

        Behavior on color {
            ColorAnimation {
                duration: Style.animationFast
            }

        }

    }

    Row {
        id: row

        spacing: Style.marginXXS

        NText {
            id: prefix

            text: "外気温は "
            anchors.verticalCenter: parent.verticalCenter
            font.family: Style.fontJp
            color: mouse.hovered ? Colors.md3.on_primary : Colors.md3.inverse_primary

            Behavior on color {
                ColorAnimation {
                    duration: Style.animationFast
                }

            }

        }

        NText {
            id: tempText

            property string temp: {
                if (!weatherReady)
                    return "";

                return LocationService.data.weather.current_weather.temperature;
            }

            text: temp
            anchors.verticalCenter: parent.verticalCenter
            color: Colors.md3.primary
        }

        NText {
            id: suffix

            text: "°C"
            anchors.verticalCenter: parent.verticalCenter
            color: mouse.hovered ? Colors.md3.on_primary : Colors.md3.inverse_primary

            Behavior on color {
                ColorAnimation {
                    duration: Style.animationFast
                }

            }

        }

    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            PanelService.getPanel("weatherMenuPanel", screen)?.toggle(parent);
        }
    }

    HoverHandler {
        id: mouse

        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    }

}

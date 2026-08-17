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

    Row {
        id: row

        spacing: Style.marginXXS

        NText {
            id: prefix

            text: "外気温は "
            anchors.verticalCenter: parent.verticalCenter
            font.family: Style.fontJp
            color: Colors.md3.inverse_primary
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
            color: Colors.md3.inverse_primary
        }

    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            PanelService.getPanel("weatherMenuPanel", screen)?.toggle(parent);
        }
    }

}

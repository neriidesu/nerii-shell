import QtQuick
import Quickshell
import qs.Commons
import qs.Services

Item {
    id: root

    readonly property bool weatherReady: Config.updateWeather && (LocationService.data.weather !== null)

    implicitHeight: row.height
    implicitWidth: row.width

    Row {
        id: row

        spacing: 2

        Text {
            id: prefix

            text: "外気温は"
            anchors.verticalCenter: parent.verticalCenter
            font.family: Fonts.jp
            color: Colors.md3.inverse_primary
        }

        Text {
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

        Text {
            id: suffix

            text: "°C"
            anchors.verticalCenter: parent.verticalCenter
            color: Colors.md3.inverse_primary
        }

    }

}

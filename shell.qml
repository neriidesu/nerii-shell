import QtQuick
import Quickshell

ShellRoot {
    PanelWindow {
        implicitHeight: 30
        color: Colors.background_dim

        anchors {
            top: true
            left: true
            right: true
        }

        Text {
            anchors.centerIn: parent
            text: Qt.formatDateTime(clock.date, "hh:mm")
            color: Colors.foreground
        }

        SystemClock {
            id: clock

            precision: SystemClock.Minutes
        }

    }

}

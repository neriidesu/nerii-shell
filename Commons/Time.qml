import QtQuick
import Quickshell
pragma Singleton

Singleton {
    id: root

    readonly property string time: {
        Qt.formatDateTime(clock.date, "hh:mm");
    }

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

}

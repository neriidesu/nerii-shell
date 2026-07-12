import QtQuick
import Quickshell
pragma Singleton

Singleton {
    id: root

    readonly property string time: {
        Qt.formatDateTime(clock.date, "hh:mm");
    }
    readonly property string date: {
        Qt.formatDateTime(clock.date, "yyyy-MM-dd");
    }
    readonly property string jp_time: {
        Qt.formatDateTime(clock.date, "hh時mm分");
    }
    readonly property string jp_date: {
        Qt.formatDateTime(clock.date, "yyyy年MM月dd日");
    }

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

}

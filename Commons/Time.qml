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

    // Formats a Date object into a YYYYMMDD-HHMMSS string.
    function getFormattedTimestamp(date) {
        if (!date)
            date = new Date();

        const year = date.getFullYear();
        // getMonth() is zero-based, so we add 1
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const hours = String(date.getHours()).padStart(2, '0');
        const minutes = String(date.getMinutes()).padStart(2, '0');
        const seconds = String(date.getSeconds()).padStart(2, '0');
        return `${year}${month}${day}-${hours}${minutes}${seconds}`;
    }

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

}

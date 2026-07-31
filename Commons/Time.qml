import QtQuick
import Quickshell
pragma Singleton

Singleton {
    id: root

    // Current date
    property var now: new Date()
    // Returns a Unix Timestamp (in seconds)
    readonly property int timestamp: {
        return Math.floor(root.now / 1000);
    }
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

    // Format a date into
    function formatRelativeTime(date) {
        if (!date)
            return "";

        const diff = Date.now() - date.getTime();
        if (diff < 60000)
            return "now";

        if (diff < 120000)
            return "1 minute ago";

        if (diff < 3.6e+06)
            return Math.floor(diff / 60000) + " minutes ago";

        if (diff < 7.2e+06)
            return "1 hour ago";

        if (diff < 8.64e+07)
            return Math.floor(diff / 3.6e+06) + " minutes ago";

        if (diff < 1.728e+08)
            return "1 day ago";

        return Math.floor(diff / 8.64e+07) + " days ago";
    }

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

}

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
pragma Singleton

Singleton {
    id: root

    function showNotice(summary, body, urgency = "normal") {
        notifProcess.exec(["sh", "-c", `notify-send -u ${urgency} '${summary}' '${body}' `]);
    }

    function showIconNotice(summary, body, icon) {
        notifProcess.exec(["sh", "-c", `notify-send '${summary}' '${body}' -i '${icon}'`]);
    }

    Process {
        id: notifProcess
    }

}

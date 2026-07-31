import QtQuick
import Quickshell
import qs.Commons

Item {
    property var launcher: null
    property string name: "Commands"

    function handleCommand(query) {
        return query.startsWith(">cmd");
    }

    function commands() {
        return [{
            "name": ">cmd",
            "description": "Runs a command in the terminal",
            "icon": "",
            "isTablerIcon": true,
            "isImage": false,
            "onActivate": function() {
                launcher.setSearchText(">cmd ");
            }
        }];
    }

    function getResults(query) {
        if (!query.startsWith(">cmd"))
            return [];

        let expression = query.substring(4).trim();
        return [{
            "name": "Command",
            "description": "Runs a command in the terminal",
            "icon": "",
            "isTablerIcon": true,
            "isImage": false,
            "onActivate": function() {
                launcher.closeImmediately();
                Qt.callLater(() => {
                    Logger.d("CommandProvider", "Executing shell command: " + expression);
                    Quickshell.execDetached(["sh", "-c", expression]);
                });
            }
        }];
    }

}

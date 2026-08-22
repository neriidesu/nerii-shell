import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services

Item {
    property var launcher: null
    property string name: "Reminders"

    function handleCommand(query) {
        return query.startsWith(">reminder");
    }

    function commands() {
        return [{
            "name": ">reminder",
            "description": "Shows your reminders",
            "icon": "",
            "isTablerIcon": true,
            "isImage": false,
            "onActivate": function() {
                launcher.setSearchText(">reminder ");
            }
        }, {
            "name": ">reminder set",
            "description": "Sets a reminder with a message (reminder set <time> <message>) ",
            "icon": "",
            "isTablerIcon": true,
            "isImage": false,
            "onActivate": function() {
                launcher.setSearchText(">reminder set ");
            }
        }];
    }

    function getResults(query) {
        if (!query.startsWith(">reminder"))
            return [];

        let trimmed = query.substring(10).trim();
        if (trimmed.startsWith("set")) {
            let exp = trimmed.substring(3).trim();
            if (exp == "")
                return [{
                "name": ">reminder set <time>; <message>",
                "description": "Sets a reminder with a message ",
                "icon": "",
                "isTablerIcon": true,
                "isImage": false,
                "onActivate": function() {
                }
            }];

            let arr = exp.split(';');
            let message = arr.pop().trim();
            let timeArr = arr[0].split(' ');
            let time = 0;
            for (const item of timeArr) {
                if (!/^\d{1,}[h,m,s]$/.test(item))
                    return [{
                    "name": `Reminder: ${message}`,
                    "description": `Invalid time`,
                    "icon": "",
                    "isTablerIcon": true,
                    "isImage": false,
                    "onActivate": function() {
                    }
                }];

                if (item.endsWith('h'))
                    time += item.slice(0, -1) * 60 * 60;

                if (item.endsWith('m'))
                    time += item.slice(0, -1) * 60;

                if (item.endsWith('s'))
                    time += Number(item.slice(0, -1));

            }
            return [{
                "name": `Reminder: ${message}`,
                "description": `In ${arr.join(' ')}`,
                "icon": "",
                "isTablerIcon": true,
                "isImage": false,
                "onActivate": function() {
                    TimerService.start(message, time);
                    launcher.close();
                }
            }];
        }
        let timers = TimerService.getTimers();
        if (timers == null)
            return [];

        let results = [];
        for (const timer of timers) {
            let name = timer.name;
            if (!timer.name)
                name = timer.id;

            Logger.d(name);
            results.push({
                "name": name,
                "description": timer.time,
                "icon": "",
                "timerId": timer.id,
                "isTablerIcon": true,
                "isImage": false,
                "onActivate": function() {
                }
            });
        }
        return results;
    }

    function canDeleteItem(item) {
        return item && !!item.timerId;
    }

    function deleteItem(item) {
        if (!item || !item.timerId)
            return ;

        // Delete the item
        TimerService.deleteById(item.timerId);
        launcher.close();
    }

}

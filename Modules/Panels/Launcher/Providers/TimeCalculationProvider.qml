import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
    // return timeIn(trimmed.substring(2).trim());

    property var launcher: null
    property string name: "Time"

    function handleCommand(query) {
        return query.startsWith(">time");
    }

    function commands() {
        return [{
            "name": ">time in",
            "description": "Gets the time in <hh>h <mm>m",
            "icon": "",
            "isTablerIcon": true,
            "isImage": false,
            "onActivate": function() {
                launcher.setSearchText(">time in ");
            }
        }, {
            "name": ">time until",
            "description": "Gets the time until <hh>h <mm>m",
            "icon": "",
            "isTablerIcon": true,
            "isImage": false,
            "onActivate": function() {
                launcher.setSearchText(">time until ");
            }
        }];
    }

    function getResults(query) {
        if (!query.startsWith(">time"))
            return [];

        let trimmed = query.substring(5).trim();
        if (query.startsWith(">time in")) {
            let t = timeIn(trimmed.substring(2).trim());
            if (t == -1)
                return [];

            return [{
                "name": Time.formatStandard(new Date(t * 1000), new Date()),
                "description": "Press enter to copy result",
                "icon": "󰃬",
                "isTablerIcon": true,
                "isImage": false,
                "provider": root,
                "onActivate": function() {
                    // Copy result to clipboard via xclip
                    Quickshell.execDetached(["sh", "-c", "echo -n '" + query.replace(/'/g, "'\\''") + "' | wl-copy"]);
                    ToastService.showNotice("Copied result to clipboard", query);
                    if (launcher)
                        launcher.close();

                }
            }];
        }
        if (query.startsWith(">time until")) {
            let t = timeUntil(trimmed.substring(5).trim());
            return [{
                "name": t,
                "description": "Press enter to copy result",
                "icon": "󰃬",
                "isTablerIcon": true,
                "isImage": false,
                "provider": root,
                "onActivate": function() {
                    // Copy result to clipboard via xclip
                    Quickshell.execDetached(["sh", "-c", "echo -n '" + query.replace(/'/g, "'\\''") + "' | wl-copy"]);
                    ToastService.showNotice("Copied result to clipboard", query);
                    if (launcher)
                        launcher.close();

                }
            }];
        }
        return commands();
    }

    function timeIn(query) {
        let exp = query.split(' ');
        let time = Time.timestamp;
        for (const item of exp) {
            // Check if input matches format
            if (!/^\d{1,}([y,d,h,m,s]|mo)$/.test(item))
                return -1;

            if (item.endsWith('y')) {
                var t = new Date(time * 1000);
                t.setFullYear(t.getFullYear() + Number(item.slice(0, -1)));
                time = t / 1000;
            }
            if (item.endsWith('mo')) {
                var t = new Date(time * 1000);
                var newMonths = t.getMonth() + Number(item.slice(0, -2));
                t.setFullYear(t.getFullYear() + Math.floor(newMonths / 12));
                t.setMonth(newMonths % 12);
                time = t / 1000;
            }
            if (item.endsWith('d'))
                time += item.slice(0, -1) * 60 * 60 * 24;

            if (item.endsWith('h'))
                time += item.slice(0, -1) * 60 * 60;

            if (item.endsWith('m'))
                time += item.slice(0, -1) * 60;

            if (item.endsWith('s'))
                time += Number(item.slice(0, -1));

        }
        return time;
    }

    function timeUntil(query) {
        var t = new Date();
        var exp = query;
        if (/^(([0-1]\d)|(2[0-3])):[0-5]\d($|:[0-5]\d$)/.test(query))
            exp = `${t.getFullYear()}-${String(t.getMonth() +1).padStart(2, '0')}-${String(t.getDate()).padStart(2, '0')}T${query}`;

        t = Date.parse(exp);
        if (isNaN(t))
            return "Invalid Date";

        t = new Date(t);
        const now = new Date();
        // time in seconds until date
        let time = Math.floor((t.getTime() - now.getTime()) / 1000);
        let days = Math.floor(time / 86400);
        let hours = Math.floor((time / 3600) - (Math.floor(time / 86400) * 24));
        let minutes = Math.floor((time / 60) - (Math.floor(time / 3600) * 60));
        let seconds = Math.floor(time - (Math.floor(time / 60) * 60));
        Logger.d("", time, t.getTime(), now.getTime());
        if (days > 0)
            return `${days}d ${hours}h ${minutes}m ${seconds}s`;

        if (hours > 0)
            return `${hours}h ${minutes}m ${seconds}s`;

        if (minutes > 0)
            return `${minutes}m ${seconds}s`;

        return `${seconds}s`;
    }

}

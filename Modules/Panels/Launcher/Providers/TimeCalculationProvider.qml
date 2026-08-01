import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
    // return timeIn(trimmed.substring(2).trim());

    property var launcher: null
    property string name: "Time"

    function handleCommand(query) {
        return query.startsWith(">time in");
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
        }];
    }

    function getResults(query) {
        if (!query.startsWith(">time in"))
            return [];

        let trimmed = query.substring(5).trim();
        return timeIn(trimmed.substring(2).trim());
    }

    function timeIn(query) {
        let exp = query.split(' ');
        let time = Time.timestamp;
        for (const item of exp) {
            // Check if input matches format
            if (!/^\d{1,}([y,d,h,m,s]|mo)$/.test(item))
                return [];

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
        return [{
            "name": Time.formatStandard(new Date(time * 1000), new Date()),
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

}

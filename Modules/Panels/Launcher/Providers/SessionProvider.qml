import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services

Item {
    property var launcher: null

    function commands() {
        return [{
            "name": ">session lock",
            "description": "Locks the computer",
            "icon": "󰌾",
            "isTablerIcon": true,
            "isImage": false,
            "onActivate": function() {
                launcher.closeImmediately();
                CompositorService.lock();
            }
        }, {
            "name": ">session logout",
            "description": "Logs out of the session",
            "icon": "󰍃",
            "isTablerIcon": true,
            "isImage": false,
            "onActivate": function() {
                launcher.closeImmediately();
                CompositorService.logout();
            }
        }, {
            "name": ">session sleep",
            "description": "Makes the computer go to sleep",
            "icon": "󰤄",
            "isTablerIcon": true,
            "isImage": false,
            "onActivate": function() {
                launcher.closeImmediately();
                CompositorService.hibernate();
            }
        }, {
            "name": ">session reboot",
            "description": "Reboots the computer",
            "icon": "󰜉",
            "isTablerIcon": true,
            "isImage": false,
            "onActivate": function() {
                launcher.closeImmediately();
                CompositorService.reboot();
            }
        }, {
            "name": ">session shutdown",
            "description": "Shuts down the computer",
            "icon": "󰐥",
            "isTablerIcon": true,
            "isImage": false,
            "onActivate": function() {
                launcher.closeImmediately();
                CompositorService.shutdown();
            }
        }];
    }

}

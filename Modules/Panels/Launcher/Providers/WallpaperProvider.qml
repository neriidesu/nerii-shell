import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services

Item {
    property var launcher: null

    function commands() {
        return [{
            "name": ">wallpaper kill",
            "description": "Kills the wallpaper daemon",
            "icon": "󰸉",
            "isTablerIcon": true,
            "isImage": false,
            "onActivate": function() {
                WallpaperService.kill();
                launcher.close();
            }
        }, {
            "name": ">wallpaper restart",
            "description": "Restarts the wallpaper daemon",
            "icon": "󰸉",
            "isTablerIcon": true,
            "isImage": false,
            "onActivate": function() {
                WallpaperService.kill();
                WallpaperService.startWallpaper();
                launcher.close();
            }
        }, {
            "name": ">wallpaper writelwe",
            "description": "Writes new linux-wallpaperengine previews",
            "icon": "󰸉",
            "isTablerIcon": true,
            "isImage": false,
            "onActivate": function() {
                WallpaperService.kill();
                WallpaperService.writeLweFiles();
                launcher.close();
            }
        }];
    }

}

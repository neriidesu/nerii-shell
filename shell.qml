// TODO: clipboard history
// TODO: wallpaper switcher
// TODO: wofi & wofi calc replacement
// TODO: Media panel
// TODO: Custom Styles

import QtQuick
import Quickshell
import qs.Commons
import qs.Modules.Bar
import qs.Modules.MainScreen
import qs.Services

ShellRoot {
    property bool configLoaded: false

    Component.onCompleted: {
        Logger.i("Shell", "---------------------------");
        Logger.i("Shell", "nerii-shell Hewwo! /`._.´\\");
        Logger.i("Shell", "---------------------------");
    }

    Connections {
        function onConfigLoaded() {
            configLoaded = true;
        }

        target: Config ? Config : null
    }

    Loader {
        active: configLoaded

        sourceComponent: Item {
            Component.onCompleted: {
                WallpaperService.init();
                Qt.callLater(function() {
                    LocationService.init();
                    IPCService.init();
                });
            }

            AllScreens {
            }

        }

    }

}

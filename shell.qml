// TODO: Start menu
// TODO: Media panel
// TODO: Weather panel

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
                Qt.callLater(function() {
                    WallpaperService.init();
                    LocationService.init();
                    IPCService.init();
                });
            }

            AllScreens {
            }

        }

    }

}

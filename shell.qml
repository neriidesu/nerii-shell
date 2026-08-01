// TODO: wallpaper switcher
// TODO: Media panel
// TODO: Custom Styles

import QtQuick
import Quickshell
import qs.Commons
import qs.Modules.Bar
import qs.Modules.MainScreen
import qs.Modules.Panels.Launcher
import qs.Services

ShellRoot {
    property bool configLoaded: false
    property bool shellStateLoaded: false

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

    Connections {
        function onIsLoadedChanged() {
            if (ShellState.isLoaded)
                shellStateLoaded = true;

        }

        target: ShellState ? ShellState : null
    }

    Loader {
        active: configLoaded && shellStateLoaded

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

            // Launcher overlay window (for overlay layer mode)
            Loader {
                active: true

                sourceComponent: Component {
                    LauncherOverlayWindow {
                    }

                }

            }

        }

    }

}

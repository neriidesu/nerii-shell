import QtQuick
import Quickshell
import qs.Commons
import qs.Modules.Bar
import qs.Modules.Core
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

            Variants {
                model: Quickshell.screens

                delegate: Item {
                    property var modelData

                    Bar {
                        screen: modelData
                        Component.onCompleted: {
                            Logger.d("Shell", "Bar loaded for screen:", modelData.name);
                        }
                    }

                    PanelContainer {
                        screen: modelData
                        Component.onCompleted: {
                            Logger.d("Shell", "PanelContainer loaded for screen:", modelData.name);
                        }
                    }

                    PopupMenuWindow {
                        screen: modelData
                        Component.onCompleted: {
                            Logger.d("Shell", "PopupMenuWindow loaded for screen:", modelData.name);
                        }
                    }

                }

            }

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

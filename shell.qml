import QtQuick
import Quickshell
import qs.Commons
import qs.Modules.Bar
import qs.Modules.MainScreen
import qs.Services

ShellRoot {
    // Variants {
    //     model: Quickshell.screens
    //     Bar {
    //         required property var modelData
    //         screen: modelData
    //     }
    // }

    Loader {

        sourceComponent: Item {
            Component.onCompleted: {
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

import QtQuick
import Quickshell
import qs.Commons
import qs.Modules.Bar
import qs.Services

ShellRoot {
    Loader {

        sourceComponent: Item {
            Component.onCompleted: {
                Qt.callLater(function() {
                    IPCService.init();
                });
            }
        }

    }

    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData

            screen: modelData
        }

    }

}

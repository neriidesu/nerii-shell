import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Modules.Bar.Widgets

PanelWindow {
    // Wayland layer configuration
    WlrLayershell.namespace: "nerii-shell-bar-" + (screen?.name || "unknown")
    WlrLayershell.layer: WlrLayer.Top

    id: barWindow

    readonly property real barMargin: Config.data.bar.barMargin
    readonly property real barHeight: Style.barHeight

    color: "transparent"
    // Set a tight window size
    implicitWidth: barWindow.screen.width
    implicitHeight: barHeight

    // Anchor to the bar's edge
    anchors {
        top: true
        left: true
        right: true
    }

    // Handle floating margins
    margins {
        top: barMargin
        left: barMargin
        right: barMargin
    }

    // Bar content loader - loaded once, stays active for lifetime
    Loader {
        // required property var modelData

        id: barLoader

        anchors.fill: parent

        sourceComponent: Item {
            id: bar_root

            property ShellScreen screen: null

            anchors.fill: parent
            screen: barWindow.screen

            LeftModules {
                anchors {
                    left: parent.left
                    bottom: parent.bottom
                    top: parent.top
                }

            }

            CenterModules {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    top: parent.top
                }

            }

            RightModules {
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                    top: parent.top
                }

            }

        }

    }

}

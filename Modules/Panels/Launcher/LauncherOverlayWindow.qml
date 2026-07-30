import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Services
import qs.Widgets

// Standalone launcher window for Overlay layer mode
// This window appears above fullscreen windows and does not attach to the bar
Variants {
    id: launcherVariants

    model: Quickshell.screens

    delegate: Loader {
        id: windowLoader

        required property ShellScreen modelData

        active: PanelService.overlayLauncherOpen && PanelService.overlayLauncherScreen == modelData

        sourceComponent: PanelWindow {
            id: launcherWindow

            readonly property int barThickness: Math.round(Style.barHeight + Config.data.bar.barMargin)
            readonly property int listPanelWidth: 500
            readonly property int previewPanelWidth: 400

            screen: windowLoader.modelData
            color: "transparent"
            WlrLayershell.namespace: "nerii-shell-launcher-overlay-" + (screen.name || "unknown") // add ? after screen
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            // Dimmer background (click to close)
            Rectangle {
                anchors.fill: parent
                color: "transparent"

                MouseArea {
                    anchors.fill: parent
                    onClicked: PanelService.closeOverlayLauncher()
                }

            }

            Item {
                id: launcherPanel

                width: Math.round(Math.max(parent.width * 0.25, launcherWindow.listPanelWidth + Style.margin2L * 2))
                height: Math.round(Math.max(parent.height * 0.5, 600))
                clip: false
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.topMargin: barThickness

                Rectangle {
                    anchors.fill: parent
                    color: Qt.alpha(Colors.md3.surface, 0.75)
                    radius: Style.radiusM
                    border.color: Colors.md3.primary
                    border.width: Style.borderS
                }

                LauncherCore {
                    id: launcherCore

                    anchors.fill: parent
                    screen: windowLoader.modelData
                    isOpen: true
                    onRequestClose: PanelService.closeOverlayLauncher()
                    onRequestCloseImmediately: PanelService.closeOverlayLauncherImmediately()
                    Component.onCompleted: PanelService.overlayLauncherCore = launcherCore
                    Component.onDestruction: PanelService.overlayLauncherCore = null
                }

            }

        }

    }

}

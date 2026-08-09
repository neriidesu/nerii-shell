import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Services
import qs.Modules.Core
// Panels
import qs.Modules.Panels.SessionMenu
import qs.Modules.Panels.WeatherMenu
import qs.Modules.Panels.Wallpaper

PanelWindow {
    id: root
    property bool isPanelOpen: (PanelService.openedPanel !== null) && (PanelService.openedPanel.screen === screen)
    property bool isPanelClosing: (PanelService.openedPanel !== null) && PanelService.openedPanel.isClosing
    property bool isAnyPanelOpen: PanelService.openedPanel !== null
    
    color: "transparent"
    
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Component.onCompleted: {
        Logger.d("PanelContainer", "Initialized for screen:", screen?.name, "- Dimensions:", screen.width, "x", screen?.height, "- Position:", screen?.x, ",", screen?.y);
    }
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "nerii-shell-background-" + (screen?.name || "unknown")
    WlrLayershell.keyboardFocus: {
        // No panel open anywhere: no keyboard focus needed
        if (!root.isAnyPanelOpen)
            return WlrKeyboardFocus.None;

        // Panel open on THIS screen: use panel's preferred focus mode
        if (root.isPanelOpen) {
            // Hyprland's Exclusive captures ALL input globally (including pointer),
            // preventing click-to-close from working on other monitors.
            // Workaround: briefly use Exclusive when panel opens (for text input focus),
            // then switch to OnDemand (for click-to-close on other screens).
            return PanelService.isInitializingKeyboard ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand;
        }
        // Panel open on ANOTHER screen: OnDemand allows receiving pointer events for click-to-close
        return WlrKeyboardFocus.OnDemand;
    }

    mask: Region {
        id: clickableMask
        x: 0
        y: 0
        width: root.width
        height: root.height
        intersection: Intersection.Xor

        // Background region for click-to-close - reactive sizing
        // Uses isAnyPanelOpen so clicking on any screen's background closes the panel
        Region {
          id: backgroundMaskRegion
          x: 0
          y: 0
          width: root.isAnyPanelOpen ? root.width : 0
          height: root.isAnyPanelOpen ? root.height : 0
          intersection: Intersection.Subtract
        }
    }

    Item {
        id: container
        width: root.width
        height: root.height

        // Background MouseArea for closing panels when clicking outside
        // Uses isAnyPanelOpen so clicking on any screen's background closes the panel
        MouseArea {
            anchors.fill: parent
            enabled: root.isAnyPanelOpen
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            onClicked: mouse => {
                if (PanelService.openedPanel) {
                    PanelService.openedPanel.close();
                }
            }
            z: 0 // Behind panels and bar
        }

        // --------------
        // --- Panels ---
        // --------------

        SessionMenu {
            id: sessionMenuPanel
            screen: root.screen
            objectName: "sessionMenuPanel-" + (root.screen?.name || "unknown")
        }
        WeatherMenu{
            id: weatherMenuPanel
            objectName: "weatherMenuPanel-" + (root.screen?.name || "unknown")
            screen: root.screen
        }
        Wallpaper{
            id: wallpaperPanel
            objectName: "wallpaperPanel-" + (root.screen?.name || "unknown")
            screen: root.screen
        }
    }


    // Centralized Keyboard Shortcuts

    // These shortcuts delegate to the opened panel's handler functions
    // Panels can implement: onEscapePressed, onTabPressed, onBackTabPressed,
    // onUpPressed, onDownPressed, onReturnPressed, etc...
    Shortcut {
        sequence: "Esc"
        enabled: root.isPanelOpen && (PanelService.openedPanel.onEscapePressed !== undefined) && !PanelService.isKeybindRecording
        onActivated: PanelService.openedPanel.onEscapePressed()
    }

    Shortcut {
        sequence: "Tab"
        enabled: root.isPanelOpen && (PanelService.openedPanel.onTabPressed !== undefined)
        onActivated: PanelService.openedPanel.onTabPressed()
    }

    Shortcut {
        sequence: "Backtab"
        enabled: root.isPanelOpen && (PanelService.openedPanel.onBackTabPressed !== undefined)
        onActivated: PanelService.openedPanel.onBackTabPressed()
    }

    Shortcut {
        sequence: "Up"
        enabled: root.isPanelOpen && (PanelService.openedPanel.onUpPressed !== undefined) && !PanelService.isKeybindRecording
        onActivated: PanelService.openedPanel.onUpPressed()
    }

    Shortcut {
        sequence: "Down"
        enabled: root.isPanelOpen && (PanelService.openedPanel.onDownPressed !== undefined) && !PanelService.isKeybindRecording
        onActivated: PanelService.openedPanel.onDownPressed()
    }

    Shortcut {
        sequences: ["Enter", "Return"]
        enabled: root.isPanelOpen && (PanelService.openedPanel.onEnterPressed !== undefined) && !PanelService.isKeybindRecording
        onActivated: PanelService.openedPanel.onEnterPressed()
    }

    Shortcut {
        sequence: "Left"
        enabled: root.isPanelOpen && (PanelService.openedPanel.onLeftPressed !== undefined) && !PanelService.isKeybindRecording
        onActivated: PanelService.openedPanel.onLeftPressed()
    }

    Shortcut {
        sequence: "Right"
        enabled: root.isPanelOpen && (PanelService.openedPanel.onRightPressed !== undefined) && !PanelService.isKeybindRecording
        onActivated: PanelService.openedPanel.onRightPressed()
    }

    Shortcut {
        sequence: "Home"
        enabled: root.isPanelOpen && (PanelService.openedPanel.onHomePressed !== undefined)
        onActivated: PanelService.openedPanel.onHomePressed()
    }

    Shortcut {
        sequence: "End"
        enabled: root.isPanelOpen && (PanelService.openedPanel.onEndPressed !== undefined)
        onActivated: PanelService.openedPanel.onEndPressed()
    }

    Shortcut {
        sequence: "PgUp"
        enabled: root.isPanelOpen && (PanelService.openedPanel.onPageUpPressed !== undefined)
        onActivated: PanelService.openedPanel.onPageUpPressed()
    }

    Shortcut {
        sequence: "PgDown"
        enabled: root.isPanelOpen && (PanelService.openedPanel.onPageDownPressed !== undefined)
        onActivated: PanelService.openedPanel.onPageDownPressed()
    }

}

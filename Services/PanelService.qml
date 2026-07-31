import QtQuick
import Quickshell
import qs.Commons
pragma Singleton

Singleton {
    id: root

    // Panels
    property var registeredPanels: ({
    })
    property var openedPanel: null
    property var closingPanel: null
    property bool closedImmediately: false
    // Global state for keybind recording components to block global shortcuts
    property bool isKeybindRecording: false
    // Popup menu windows (one per screen) - used for both tray menus and context menus
    property var popupMenuWindows: ({
    })
    // Overlay launcher state (separate from normal panels)
    property bool overlayLauncherOpen: false
    property var overlayLauncherScreen: null
    property var overlayLauncherCore: null // Reference to LauncherCore when overlay is active
    // Brief window after panel opens where Exclusive keyboard is allowed on Hyprland
    // This allows text inputs to receive focus, then switches to OnDemand for click-to-close
    property bool isInitializingKeyboard: false
    // Background slot assignments for dynamic panel background rendering
    // Slot 0: currently opening/open panel, Slot 1: closing panel
    property var backgroundSlotAssignments: [null, null]

    signal willOpen()
    signal didClose()
    signal popupMenuWindowRegistered(var screen)
    signal slotAssignmentChanged(int slotIndex, var panel)

    // Register this panel (called after panel is loaded)
    function registerPanel(panel) {
        registeredPanels[panel.objectName] = panel;
        Logger.d("PanelService", "Registered panel:", panel.objectName);
    }

    // Register popup menu window for a screen
    function registerPopupMenuWindow(screen, window) {
        if (!screen || !window)
            return ;

        var key = screen.name;
        popupMenuWindows[key] = window;
        Logger.d("PanelService", "Registered popup menu window for screen:", key);
        popupMenuWindowRegistered(screen);
    }

    // Unregister popup menu window for a screen (called on destruction)
    function unregisterPopupMenuWindow(screen) {
        if (!screen)
            return ;

        var key = screen.name;
        delete popupMenuWindows[key];
        Logger.d("PanelService", "Unregistered popup menu window for screen:", key);
    }

    // Get popup menu window for a screen
    function getPopupMenuWindow(screen) {
        if (!screen)
            return null;

        return popupMenuWindows[screen.name] || null;
    }

    // Show a context menu with proper handling for all compositors
    // Optional targetItem: if provided, menu will be horizontally centered on this item instead of anchorItem
    function showContextMenu(contextMenu, anchorItem, screen, targetItem) {
        if (!contextMenu || !anchorItem)
            return ;

        // Close any previously opened context menu first
        closeContextMenu(screen);
        var popupMenuWindow = getPopupMenuWindow(screen);
        if (popupMenuWindow) {
            popupMenuWindow.showContextMenu(contextMenu);
            contextMenu.openAtItem(anchorItem, screen, targetItem);
        }
    }

    // Close any open context menu or popup menu window
    function closeContextMenu(screen) {
        var popupMenuWindow = getPopupMenuWindow(screen);
        if (popupMenuWindow && popupMenuWindow.visible)
            popupMenuWindow.close();

    }

    // Show a tray menu with proper handling for all compositors
    // Returns true if menu was shown successfully
    function showTrayMenu(screen, trayItem, trayMenu, anchorItem, menuX, menuY, widgetSection, widgetIndex) {
        if (!trayItem || !trayMenu || !anchorItem)
            return false;

        // Close any previously opened menu first
        closeContextMenu(screen);
        trayMenu.trayItem = trayItem;
        trayMenu.widgetSection = widgetSection;
        trayMenu.widgetIndex = widgetIndex;
        var popupMenuWindow = getPopupMenuWindow(screen);
        if (popupMenuWindow) {
            popupMenuWindow.open();
            trayMenu.showAt(anchorItem, menuX, menuY);
        } else {
            return false;
        }
        return true;
    }

    // Returns a panel (loads it on-demand if not yet loaded)
    // By default, if panel not found on screen, tries other screens (favoring 0x0)
    // Pass fallback=false to disable this behavior
    function getPanel(name, screen, fallback = true) {
        if (!screen) {
            Logger.d("PanelService", "missing screen for getPanel:", name);
            // If no screen specified, return the first matching panel
            for (var key in registeredPanels) {
                if (key.startsWith(name + "-"))
                    return registeredPanels[key];

            }
            return null;
        }
        var panelKey = `${name}-${screen.name}`;
        // Check if panel is already loaded
        if (registeredPanels[panelKey])
            return registeredPanels[panelKey];

        // If fallback enabled, try to find panel on another screen
        if (fallback) {
            // First try the primary screen (0x0)
            var fallbackScreen = findFallbackScreen();
            if (fallbackScreen && fallbackScreen.name !== screen.name) {
                var fallbackKey = `${name}-${fallbackScreen.name}`;
                if (registeredPanels[fallbackKey]) {
                    Logger.d("PanelService", "Panel fallback from", screen.name, "to", fallbackScreen.name);
                    return registeredPanels[fallbackKey];
                }
            }
            // Try any other screen
            for (var key in registeredPanels) {
                if (key.startsWith(name + "-")) {
                    Logger.d("PanelService", "Panel fallback to first available:", key);
                    return registeredPanels[key];
                }
            }
        }
        Logger.w("PanelService", "Panel not found:", panelKey);
        return null;
    }

    // Helper to keep only one panel open at any time
    function willOpenPanel(panel) {
        // Close overlay launcher if open
        if (overlayLauncherOpen) {
            overlayLauncherOpen = false;
            overlayLauncherScreen = null;
        }
        if (openedPanel && openedPanel !== panel) {
            // Move current panel to closing slot before closing it
            closingPanel = openedPanel;
            assignToSlot(1, closingPanel);
            openedPanel.close();
        }
        // Assign new panel to open slot
        openedPanel = panel;
        assignToSlot(0, panel);
        // Start keyboard initialization period (for Hyprland workaround)
        if (panel && panel.exclusiveKeyboard) {
            isInitializingKeyboard = true;
            keyboardInitTimer.restart();
        }
        // emit signal
        willOpen();
    }

    function assignToSlot(slotIndex, panel) {
        if (backgroundSlotAssignments[slotIndex] !== panel) {
            var newAssignments = backgroundSlotAssignments.slice();
            newAssignments[slotIndex] = panel;
            backgroundSlotAssignments = newAssignments;
            slotAssignmentChanged(slotIndex, panel);
        }
    }

    function closedPanel(panel) {
        if (openedPanel && openedPanel === panel) {
            openedPanel = null;
            assignToSlot(0, null);
        }
        if (closingPanel && closingPanel === panel) {
            closingPanel = null;
            assignToSlot(1, null);
        }
        // Reset keyboard init state
        isInitializingKeyboard = false;
        keyboardInitTimer.stop();
        // emit signal
        didClose();
    }

    // Open launcher panel (handles both normal and overlay mode)
    function openLauncher(screen) {
        // Close any regular panel first
        if (openedPanel) {
            closingPanel = openedPanel;
            assignToSlot(1, closingPanel);
            openedPanel.close();
            openedPanel = null;
        }
        // Open overlay launcher
        overlayLauncherOpen = true;
        overlayLauncherScreen = screen;
        willOpen();
    }

    // Toggle launcher panel
    function toggleLauncher(screen) {
        if (overlayLauncherOpen && overlayLauncherScreen === screen)
            closeOverlayLauncher();
        else
            openLauncher(screen);
    }

    // Close overlay launcher
    function closeOverlayLauncher() {
        if (overlayLauncherOpen) {
            overlayLauncherOpen = false;
            overlayLauncherScreen = null;
            didClose();
        }
    }

    // Close overlay launcher immediately (for app launches)
    function closeOverlayLauncherImmediately() {
        if (overlayLauncherOpen) {
            closedImmediately = true;
            overlayLauncherOpen = false;
            overlayLauncherScreen = null;
            didClose();
        }
    }

    // ==================== Unified Launcher API ====================
    function isLauncherOpen(screen) {
        return overlayLauncherOpen && overlayLauncherScreen === screen;
    }

    function getLauncherSearchText(screen) {
        return overlayLauncherCore ? overlayLauncherCore.searchText : "";
    }

    function setLauncherSearchText(screen, text) {
        if (overlayLauncherCore)
            overlayLauncherCore.setSearchText(text);

    }

    function openLauncherWithSearch(screen, searchText) {
        openLauncher(screen);
        // Set search text after core is ready
        Qt.callLater(() => {
            if (overlayLauncherCore)
                overlayLauncherCore.setSearchText(searchText);

        });
    }

    function closeLauncher(screen) {
        closeOverlayLauncher();
    }

    // Timer to switch from Exclusive to OnDemand keyboard focus on Hyprland
    Timer {
        id: keyboardInitTimer

        interval: 100
        repeat: false
        onTriggered: {
            root.isInitializingKeyboard = false;
        }
    }

}

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

    signal willOpen()
    signal didClose()
    signal popupMenuWindowRegistered(var screen)

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

}

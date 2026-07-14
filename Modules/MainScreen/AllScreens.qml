import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Modules.MainScreen
import qs.Services

// ------------------------------
// MainScreen for each screen (manages bar + all panels)
// Wrapped in Loader to optimize memory - only loads when screen needs it
Variants {
    model: Quickshell.screens
    delegate: Item {
        id: windowItem
        required property ShellScreen modelData

        property bool shouldBeActive: {
            if (!modelData || !modelData.name) {
                return false;
            }

            Logger.d("AllScreens", "Screen activated: ", modelData?.name);
            return true;
        }

        property bool windowLoaded: false

        // MainScreen loader
        Loader {
            id: windowlLoader
            active: parent.shouldBeActive
            asynchronous: false

            property ShellScreen loaderScreen: modelData

            onLoaded: {
                // Signal that window is loaded so exclusion zone can be created
                parent.windowLoaded = true
            }

            sourceComponent: MainScreen {
                screen: windowlLoader.loaderScreen
            }
        }

        // Bar content in separate windows to prevent fullscreen redraws
        // Note: Window stays alive when bar is hidden (visible=false) to avoid
        // rapid Wayland surface destruction/creation that can crash compositors.
        // Content is debounce-unloaded inside BarContentWindow.
        Loader {
            active: {
                if (!parent.windowLoaded || !parent.shouldBeActive) {
                    return false;
                }
                return true;
            }
            asynchronous: false

            sourceComponent: BarContentWindow {
                screen: modelData
            }

            onLoaded: {
                Logger.d("AllScreens", "BarContentWindow created for", modelData?.name)
            }
        }

        // BarExclusionZone - created after MainScreen has fully loaded
        Loader {
            active: {
                if (!parent.windowLoaded || !parent.shouldBeActive) {
                    return false;
                }
                return true;
            }
            asynchronous: false

            sourceComponent: BarExclusionZone {
                screen: modelData
            }

            onLoaded: {
                Logger.d("AllScreens", "BarExclusionZone created for", modelData?.name);
            }
        }


        // PopupMenuWindow - reusable popup window for both tray menus and context menus
        // Stays alive when bar is hidden to avoid Wayland surface churn crashes.
        // PopupMenuWindow manages its own visibility internally.
        Loader {
            active: {
                if (!parent.windowLoaded || !parent.shouldBeActive) {
                    return false;
                }
                return true;
            }
            asynchronous: false

            sourceComponent: PopupMenuWindow {
                screen: modelData
            }

            onLoaded: {
                Logger.d("AllScreens", "PopupMenuWindow created for", modelData?.name)
            }
        }
    }
}

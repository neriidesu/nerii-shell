import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Modules.Bar
import qs.Services

/**
* BarContentWindow - Separate transparent PanelWindow for bar content
*
* This window contains only the bar widgets (content), while the background
* is rendered in MainScreen's unified Shape system. This separation prevents
* fullscreen redraws when bar widgets redraw.
*
* This component should be instantiated once per screen by AllScreens.qml
*/
PanelWindow {
    id: barWindow

    color: "transparent"

    visible: contentLoaded 

    Component.onCompleted: {
        Logger.d("BarContentWindow", "Bar content window created for screen:", barWindow.screen?.name);
    }

    // Wayland layer configuration
    WlrLayershell.namespace: "nerii-shell-bar-content-" + (barWindow.screen?.name || "unknown")
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusionMode: ExclusionMode.Ignore // Don't reserve space - BarExclusionZone in MainScreen handles that

    readonly property real barMargin: Config.data.bar.barMargin
    readonly property real barHeight: Style.barHeight

    // Hover tracking
    property bool barHovered: false

    // Check if any panel is open on this screen
    readonly property bool panelOpen: PanelService.openedPanel !== null

    // Anchor to the bar's edge
    anchors {
        top: true
        left: true
        right: true 
    }

    property bool contentLoaded: true

    // Handle floating margins
    margins {
        top: barMargin
        left: barMargin
        right: barMargin
    }

    // Set a tight window size
    implicitWidth: barWindow.screen.width
    implicitHeight: barHeight

    // Bar content loader - loaded once, stays active for lifetime
    Loader {
        id: barLoader
        anchors.fill: parent
        active: barWindow.contentLoaded

        sourceComponent: Item {
            anchors.fill: parent

            Bar {
                // required property var modelData

                screen: barWindow.screen
            }
        }
    }
}
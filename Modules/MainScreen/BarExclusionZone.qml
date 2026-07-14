import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Services

/**
* BarExclusionZone - Invisible PanelWindow that reserves exclusive space for the bar
*
* This is a minimal window that works with the compositor to reserve space,
* while the actual bar UI is rendered in MainScreen.
*/
PanelWindow {
    id: root

    property real thickness: Style.barHeight
    readonly property real barMargin: Config.barMargin

    // Invisible - just reserves space
    color: "transparent"
    // Wayland layer shell configuration
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "nerii-shell-bar-exclusion-" + (screen?.name || "unknown")
    WlrLayershell.exclusionMode: ExclusionMode.Auto

    mask: Region {
    }

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: thickness + barMargin

    Component.onCompleted: {
        Logger.d("BarExclusionZone", "Created for screen:", screen?.name);
    } 
}

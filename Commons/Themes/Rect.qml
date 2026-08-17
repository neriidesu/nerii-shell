import QtQuick
import Quickshell
import qs.Commons
import qs.Commons.Themes

Theme {
    // Bar
    readonly property real barHeight: 40
    readonly property real barMargin: 10
    readonly property bool barIsSeparate: true
    readonly property bool allowPanelConnect: false
    // Border
    readonly property bool showPanelBorders: true
    // Transparency
    readonly property real barTransparency: 0.75
    readonly property real panelTransparency: 0.5
    // Colors
    readonly property color barBackground: Colors.md3.background
    readonly property color panelBackground: Colors.md3.surface
}

import QtQuick
import Quickshell
import qs.Commons
import qs.Commons.Themes

Theme {
    // Bar
    readonly property real barHeight: 30
    readonly property real barMargin: 0
    readonly property bool barIsSeparate: false
    readonly property bool allowPanelConnect: true
    // Border
    readonly property bool showPanelBorders: false
    // Container Radii: major layout sections (sidebars, cards, content panels)
    readonly property int radiusXXXS: 0
    readonly property int radiusXXS: 2
    readonly property int radiusXS: 4
    readonly property int radiusS: 6
    readonly property int radiusM: 8
    readonly property int radiusL: 12
    // Transparency
    readonly property real barTransparency: 1
    readonly property real panelTransparency: 1
    // Colors
    readonly property color barBackground: Colors.md3.surface
    readonly property color panelBackground: Colors.md3.surface
}

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
    // Font size
    readonly property real fontSizeXXS: 8
    readonly property real fontSizeXS: 9
    readonly property real fontSizeS: 10
    readonly property real fontSizeM: 12
    readonly property real fontSizeL: 14
    readonly property real fontSizeXL: 16
    readonly property real fontSizeXXL: 18
    readonly property real fontSizeXXXL: 24
    // Font weight
    readonly property int fontWeightLight: 200
    readonly property int fontWeightRegular: 400
    readonly property int fontWeightMedium: 500
    readonly property int fontWeightSemiBold: 600
    readonly property int fontWeightBold: 700
    // Margins (for margins and spacing)
    readonly property int marginXXXS: 1
    readonly property int marginXXS: 2
    readonly property int marginXS: 4
    readonly property int marginS: 6
    readonly property int marginM: 9
    readonly property int marginL: 13
    readonly property int marginXL: 18
    // Animation duration (ms)
    readonly property int animationFaster: 75
    readonly property int animationFast: 150
    readonly property int animationNormal: 300
    readonly property int animationSlow: 450
    readonly property int animationSlowest: 750
    // Container Radii: major layout sections (sidebars, cards, content panels)
    readonly property int radiusXXXS: 0
    readonly property int radiusXXS: 2
    readonly property int radiusXS: 4
    readonly property int radiusS: 6
    readonly property int radiusM: 8
    readonly property int radiusL: 12
    // Border
    readonly property int borderS: 1
    readonly property int borderM: 2
    readonly property int borderL: 3
    readonly property bool showPanelBorders: false
    // Widgets base size
    readonly property real baseWidgetSize: 33
    readonly property real sliderWidth: 200
    // Transparency
    readonly property real barTransparency: 1
    readonly property real panelTransparency: 1
    // Colors
    readonly property color barBackground: Colors.md3.surface
    readonly property color panelBackground: Colors.md3.surface
}

import QtQuick
import Quickshell
pragma Singleton

Singleton {
    readonly property real barHeight: 40
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
    // Double margins, for proper container sizing only (e.g. height: id.implicitHeight + Style.margin2M)
    readonly property int margin2XXXS: marginXXXS * 2
    readonly property int margin2XXS: marginXXS * 2
    readonly property int margin2XS: marginXS * 2
    readonly property int margin2S: marginS * 2
    readonly property int margin2M: marginM * 2
    readonly property int margin2L: marginL * 2
    readonly property int margin2XL: marginXL * 2
    // Animation duration (ms)
    readonly property int animationFaster: 75
    readonly property int animationFast: 150
    readonly property int animationNormal: 300
    readonly property int animationSlow: 450
    readonly property int animationSlowest: 750
    // Container Radii: major layout sections (sidebars, cards, content panels)
    readonly property int radiusXXXS: 0
    readonly property int radiusXXS: 2
    readonly property int radiusXS: 2
    readonly property int radiusS: 2
    readonly property int radiusM: 0
    readonly property int radiusL: 0
    // Border
    readonly property int borderS: 1
    readonly property int borderM: 2
    readonly property int borderL: 3
    // Widgets base size
    readonly property real baseWidgetSize: 33
    readonly property real sliderWidth: 200

    // Pixel-perfect utility for centering content without subpixel positioning
    function pixelAlignCenter(containerSize, contentSize) {
        return Math.round((containerSize - contentSize) / 2);
    }

}

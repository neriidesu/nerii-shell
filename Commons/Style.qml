import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons.Themes
pragma Singleton

/*
* Universal style and theme handling
* Reveals variables from current theme as set in config and calculates others
*/
Singleton {
    property var theme
    // Bar
    readonly property real barHeight: theme.barHeight
    readonly property real barMargin: theme.barMargin
    readonly property bool barIsSeparate: theme.barIsSeparate
    readonly property bool allowPanelConnect: theme.allowPanelConnect
    // Fonts
    readonly property string fontJp: theme.fontJp
    readonly property string fontDefault: theme.fontDefault
    // Font size
    readonly property real fontSizeXXS: theme.fontSizeXXS
    readonly property real fontSizeXS: theme.fontSizeXS
    readonly property real fontSizeS: theme.fontSizeS
    readonly property real fontSizeM: theme.fontSizeM
    readonly property real fontSizeL: theme.fontSizeL
    readonly property real fontSizeXL: theme.fontSizeXL
    readonly property real fontSizeXXL: theme.fontSizeXXL
    readonly property real fontSizeXXXL: theme.fontSizeXXXL
    // Font weight
    readonly property int fontWeightLight: theme.fontWeightLight
    readonly property int fontWeightRegular: theme.fontWeightRegular
    readonly property int fontWeightMedium: theme.fontWeightMedium
    readonly property int fontWeightSemiBold: theme.fontWeightSemiBold
    readonly property int fontWeightBold: theme.fontWeightBold
    // Margins (for margins and spacing)
    readonly property int marginXXXS: theme.marginXXXS
    readonly property int marginXXS: theme.marginXXS
    readonly property int marginXS: theme.marginXS
    readonly property int marginS: theme.marginS
    readonly property int marginM: theme.marginM
    readonly property int marginL: theme.marginL
    readonly property int marginXL: theme.marginXL
    // Double margins, for proper container sizing only (e.g. height: id.implicitHeight + Style.margin2M)
    readonly property int margin2XXXS: marginXXXS * 2
    readonly property int margin2XXS: marginXXS * 2
    readonly property int margin2XS: marginXS * 2
    readonly property int margin2S: marginS * 2
    readonly property int margin2M: marginM * 2
    readonly property int margin2L: marginL * 2
    readonly property int margin2XL: marginXL * 2
    // Animation duration (ms)
    readonly property int animationFaster: theme.animationFaster
    readonly property int animationFast: theme.animationFast
    readonly property int animationNormal: theme.animationNormal
    readonly property int animationSlow: theme.animationSlow
    readonly property int animationSlowest: theme.animationSlowest
    // Container Radii: major layout sections (sidebars, cards, content panels)
    readonly property int radiusXXXS: theme.radiusXXXS
    readonly property int radiusXXS: theme.radiusXXS
    readonly property int radiusXS: theme.radiusXS
    readonly property int radiusS: theme.radiusS
    readonly property int radiusM: theme.radiusM
    readonly property int radiusL: theme.radiusL
    // Border
    readonly property int borderS: theme.borderS
    readonly property int borderM: theme.borderM
    readonly property int borderL: theme.borderL
    readonly property bool showPanelBorders: theme.showPanelBorders
    // Widgets base size
    readonly property real baseWidgetSize: theme.baseWidgetSize
    readonly property real sliderWidth: theme.sliderWidth
    // Transparency
    readonly property real barTransparency: theme.barTransparency
    readonly property real panelTransparency: theme.panelTransparency
    // Colors
    readonly property color barBackground: theme.barBackground
    readonly property color panelBackground: theme.panelBackground
    // ------------------------------
    // Calculated Colors
    readonly property color cDefaultBackground: Qt.alpha(Colors.md3.background, Style.barTransparency)
    readonly property color cBarBackground: Qt.alpha(barBackground, Style.barTransparency)
    readonly property color cPanelBackground: Qt.alpha(panelBackground, Style.panelTransparency)
    // Hyprland Variables
    property real topGap: 0
    property real bottomGap: 0
    property real leftGap: 0
    property real rightGap: 0

    // Pixel-perfect utility for centering content without subpixel positioning
    function pixelAlignCenter(containerSize, contentSize) {
        return Math.round((containerSize - contentSize) / 2);
    }

    theme: {
        switch (Config.data.misc.theme.toLowerCase()) {
        case "sleek":
            return sleek;
            break;
        case "rect":
            return rect;
            break;
        default:
            return empty;
            break;
        }
    }

    // -----------------------------------------------------
    // List all themes to allow selection through config ---
    // -----------------------------------------------------
    Theme {
        id: empty
    }

    Sleek {
        id: sleek
    }

    Rect {
        id: rect
    }

    // Get hyprland window gaps
    Process {
        id: hyprctlGapsOut

        running: true
        command: ["hyprctl", "getoption", "general.gaps_out"]

        stdout: StdioCollector {
            onStreamFinished: {
                var values = this.text.split('\n')[0].slice(14).split(' ');
                topGap = values[0];
                rightGap = values[1];
                bottomGap = values[2];
                leftGap = values[3];
            }
        }

    }

}

import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root

    property string label: ""
    property string description: ""
    property string icon: ""
    property color labelColor: Colors.md3.on_background
    property color descriptionColor: Colors.md3.on_surface_variant
    property color iconColor: Colors.md3.on_surface
    property bool showIndicator: false
    property string indicatorTooltip: ""
    property real labelSize: Style.fontSizeL

    opacity: enabled ? 1 : 0.6
    spacing: Style.marginXXS
    visible: root.label != "" || root.description != ""
    Layout.fillWidth: true

    RowLayout {
        spacing: Style.marginXS
        Layout.fillWidth: true
        visible: root.label !== ""

        Text {
            visible: root.icon !== ""
            text: root.icon
            font.pixelSize: Style.fontSizeXXL
            color: root.iconColor
            Layout.rightMargin: Style.marginS
        }

        Text {
            //   // Settings indicator dot positioned right after the text content
            //   Loader {
            //     active: root.showIndicator
            //     x: labelText.contentWidth + Style.marginXS
            //     anchors.verticalCenter: parent.verticalCenter
            //     sourceComponent: NSettingsIndicator {
            //       show: true
            //       tooltipText: root.indicatorTooltip || ""
            //     }
            //   }

            id: labelText

            Layout.fillWidth: true
            text: root.label
            font.pixelSize: root.labelSize
            font.weight: Style.fontWeightSemiBold
            color: labelColor
            wrapMode: Text.WordWrap
        }

    }

    Text {
        visible: root.description !== ""
        Layout.fillWidth: true
        text: root.description
        font.pixelSize: Style.fontSizeS
        color: root.descriptionColor
        wrapMode: Text.WordWrap
        textFormat: Text.StyledText
    }

}

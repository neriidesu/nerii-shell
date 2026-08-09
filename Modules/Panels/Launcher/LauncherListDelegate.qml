import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.Commons
import qs.Widgets

NBox {
    id: entry

    required property var modelData
    required property int index
    required property var launcher
    property bool isSelected: (!launcher.ignoreMouseHover && mouseArea.containsMouse) || (index === launcher.selectedIndex)

    width: ListView.view.width
    implicitHeight: launcher.entryHeight
    clip: true
    color: entry.isSelected ? Qt.alpha(Colors.md3.on_primary, 0.5) : "transparent"
    border.width: 0
    // Prepare item when it becomes visible (e.g., decode images)
    Component.onCompleted: {
        var provider = modelData.provider;
        if (provider && provider.prepareItem)
            provider.prepareItem(modelData);

    }

    ColumnLayout {
        id: contentLayout

        anchors.fill: parent
        anchors.margins: launcher.isCompactDensity ? Style.marginXS : Style.marginM
        spacing: launcher.isCompactDensity ? Style.marginXS : Style.marginM

        // Top row - Main entry content with action buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: launcher.isCompactDensity ? Style.marginS : Style.marginM

            // Icon badge or Image preview or Emoji
            Item {
                visible: !modelData.hideIcon
                Layout.preferredWidth: modelData.hideIcon ? 0 : launcher.badgeSize
                Layout.preferredHeight: modelData.hideIcon ? 0 : launcher.badgeSize

                // Icon background
                Rectangle {
                    anchors.fill: parent
                    radius: Style.radiusXS
                    color: Colors.md3.surface
                    visible: !modelData.isImage
                }

                // Image preview - uses provider's getImageUrl if available
                Image {
                    id: imagePreview

                    // Use provider's image revision for reactive updates
                    readonly property int _rev: modelData.provider && modelData.provider.imageRevision ? modelData.provider.imageRevision : 0

                    anchors.fill: parent
                    visible: !!modelData.isImage && !modelData.displayString
                    fillMode: Image.PreserveAspectCrop
                    // Get image URL from provider
                    source: {
                        _rev;
                        var provider = modelData.provider;
                        if (provider && provider.getImageUrl)
                            return provider.getImageUrl(modelData);

                        return "";
                    }
                    onStatusChanged: (status) => {
                        if (status === Image.Error) {
                            iconLoader.visible = true;
                            imagePreview.visible = false;
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        visible: parent.status === Image.Loading
                        color: Colors.md3.surface_variant

                        BusyIndicator {
                            anchors.centerIn: parent
                            running: true
                            width: Style.baseWidgetSize * 0.5
                            height: width
                        }

                    }

                }

                // Color swatch - shown for clipboard color entries
                Rectangle {
                    anchors.fill: parent
                    radius: Style.radiusXS
                    color: modelData.colorHex || "transparent"
                    visible: !!modelData.colorHex
                    border.color: Colors.md3.on_surface
                    border.width: Style.borderM
                }

                Loader {
                    id: iconLoader

                    anchors.fill: parent
                    anchors.margins: Style.marginXS
                    visible: (!modelData.isImage && !modelData.displayString && !modelData.colorHex) || (!!modelData.isImage && imagePreview.status === Image.Error)
                    active: visible

                    Component {
                        id: tablerIconComponent

                        NIcon {
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: modelData.icon
                            size: Style.fontSizeXXXL
                            visible: modelData.icon && !modelData.displayString
                            color: (entry.isSelected) ? Colors.md3.on_surface : Colors.md3.on_surface
                        }

                    }

                    Component {
                        id: systemIconComponent

                        IconImage {
                            anchors.fill: parent
                            source: modelData.icon ? ThemeIcons.iconFromName(modelData.icon, "application-x-executable") : ""
                            visible: modelData.icon && source !== "" && !modelData.displayString
                            asynchronous: true
                        }

                    }

                    sourceComponent: Component {
                        Loader {
                            anchors.fill: parent
                            sourceComponent: modelData.isTablerIcon ? tablerIconComponent : systemIconComponent
                        }

                    }

                }

                // String display - takes precedence when displayString is present
                NText {
                    id: stringDisplay

                    anchors.centerIn: parent
                    visible: !!modelData.displayString || (!imagePreview.visible && !iconLoader.visible)
                    text: modelData.displayString ? modelData.displayString : (modelData.name ? modelData.name.charAt(0).toUpperCase() : "?")
                    size: modelData.displayString ? (modelData.displayStringSize || Style.fontSizeXXXL) : Style.fontSizeXXL
                    font.weight: Style.fontWeightBold
                    color: modelData.displayString ? Colors.md3.on_surface : Colors.md3.on_primary
                }

                // Image type indicator overlay
                Rectangle {
                    visible: !!modelData.isImage && imagePreview.visible
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.margins: 2
                    width: formatLabel.width + Style.marginXS
                    height: formatLabel.height + Style.marginXXS
                    color: Colors.md3.surface_variant
                    radius: Style.radiusXXS

                    NText {
                        id: formatLabel

                        anchors.centerIn: parent
                        text: {
                            if (!modelData.isImage)
                                return "";

                            const desc = modelData.description || "";
                            const parts = desc.split(" \u2022 ");
                            return parts[0] || "IMG";
                        }
                        size: Style.fontSizeXXS
                        color: Colors.md3.surface_variant
                    }

                }

                // Badge icon overlay (generic indicator for any provider)
                Rectangle {
                    visible: !!modelData.badgeIcon
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.margins: 2
                    width: height
                    height: Style.fontSizeM + Style.marginXS
                    color: Colors.md3.surface_variant
                    radius: Style.radiusXXS

                    NIcon {
                        anchors.centerIn: parent
                        text: modelData.badgeIcon || ""
                        size: Style.fontSizeS
                        color: Colors.md3.surface_variant
                    }

                }

            }

            // Text content
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                NText {
                    text: modelData.name || "Unknown"
                    size: Style.fontSizeL
                    font.weight: Style.fontWeightBold
                    color: entry.isSelected ? Colors.md3.on_surface : Colors.md3.on_surface_variant
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    wrapMode: Text.Wrap
                    clip: true
                    Layout.fillWidth: true
                }

                NText {
                    text: modelData.description || ""
                    size: Style.fontSizeS
                    color: entry.isSelected ? Colors.md3.on_surface : Colors.md3.on_surface_variant
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    Layout.fillWidth: true
                    visible: text !== "" && !launcher.isCompactDensity
                }

            }

            // Action buttons row - dynamically populated from provider
            RowLayout {
                property var itemActions: {
                    if (!entry.isSelected)
                        return [];

                    var provider = modelData.provider || launcher.currentProvider;
                    if (provider && provider.getItemActions)
                        return provider.getItemActions(modelData);

                    return [];
                }

                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                spacing: Style.marginXS
                visible: entry.isSelected && itemActions.length > 0

                Repeater {
                    model: parent.itemActions

                    NButton {
                        required property var modelData

                        icon: modelData.icon
                        showIcon: true
                        showLabel: false
                        size: Style.baseWidgetSize * 0.75
                        z: 1
                        onClicked: {
                            if (modelData.action)
                                modelData.action();

                        }
                    }

                }

            }

        }

    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        z: -1
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        enabled: false
        onEntered: {
            if (!launcher.ignoreMouseHover)
                launcher.selectedIndex = entry.index;

        }
        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                launcher.selectedIndex = entry.index;
                launcher.activate();
                mouse.accepted = true;
            }
        }
        acceptedButtons: Qt.LeftButton
    }

    Behavior on color {
        ColorAnimation {
            duration: Style.animationFast
            easing.type: Easing.OutCirc
        }

    }

}

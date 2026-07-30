import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.Commons
import qs.Widgets

Item {
    id: gridEntryContainer

    required property var modelData
    required property int index
    required property var launcher
    property bool isSelected: (!launcher.ignoreMouseHover && mouseArea.containsMouse) || (index === launcher.selectedIndex)

    width: GridView.view.cellWidth
    height: GridView.view.cellHeight
    // Prepare item when it becomes visible (e.g., decode images)
    Component.onCompleted: {
        var provider = modelData.provider;
        if (provider && provider.prepareItem)
            provider.prepareItem(modelData);

    }

    NBox {
        id: gridEntry

        anchors.fill: parent
        anchors.margins: Style.marginXXS
        color: gridEntryContainer.isSelected ? Colors.md3.tertiary : Colors.md3.surface_variant
        forceOpaque: gridEntryContainer.isSelected

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: launcher.isCompactDensity ? Style.marginXS : Style.marginS
            anchors.bottomMargin: launcher.isCompactDensity ? Style.marginXS : Style.marginS
            spacing: launcher.isCompactDensity ? 0 : Style.marginXXS

            // Icon badge or Image preview or Emoji
            Item {
                // Size image at 65% of cell dimensions.
                Layout.preferredWidth: Math.round(gridEntry.width * 0.65)
                Layout.preferredHeight: Math.round(gridEntry.height * 0.65)
                Layout.alignment: Qt.AlignHCenter

                // Icon background
                Rectangle {
                    anchors.fill: parent
                    radius: Style.radiusM
                    color: Colors.md3.surface
                    visible: Settings.data.appLauncher.showIconBackground && !modelData.isImage
                }

                // Image preview - uses provider's getImageUrl if available
                Image {
                    id: gridImagePreview

                    // Use provider's image revision for reactive updates
                    readonly property int _rev: modelData.provider && modelData.provider.imageRevision ? modelData.provider.imageRevision : 0

                    anchors.fill: parent
                    visible: !!modelData.isImage && !modelData.displayString
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
                            gridIconLoader.visible = true;
                            gridImagePreview.visible = false;
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

                Loader {
                    id: gridIconLoader

                    anchors.fill: parent
                    anchors.margins: Style.marginXS
                    visible: (!modelData.isImage && !modelData.displayString) || (!!modelData.isImage && gridImagePreview.status === Image.Error)
                    active: visible
                    sourceComponent: Settings.data.appLauncher.iconMode === "tabler" && modelData.isTablerIcon ? gridTablerIconComponent : gridSystemIconComponent

                    Component {
                        id: gridTablerIconComponent

                        Text {
                            text: modelData.icon
                            font.pixelSize: Style.fontSizeXXXL
                            visible: modelData.icon && !modelData.displayString
                            color: (gridEntryContainer.isSelected) ? Colors.md3.tertiary : Colors.md3.on_surface
                        }

                    }

                    Component {
                        id: gridSystemIconComponent

                        IconImage {
                            anchors.fill: parent
                            source: modelData.icon ? ThemeIcons.iconFromName(modelData.icon, "application-x-executable") : ""
                            visible: modelData.icon && source !== "" && !modelData.displayString
                            asynchronous: true
                        }

                    }

                }

                // String display
                Text {
                    id: gridStringDisplay

                    anchors.centerIn: parent
                    visible: !!modelData.displayString || (!gridImagePreview.visible && !gridIconLoader.visible)
                    text: modelData.displayString ? modelData.displayString : (modelData.name ? modelData.name.charAt(0).toUpperCase() : "?")
                    font.pixelSize: {
                        if (modelData.displayString) {
                            // Use custom size if provided, otherwise default scaling
                            if (modelData.displayStringSize)
                                return modelData.displayStringSize * Style.uiScaleRatio;

                            if (launcher.providerHasDisplayString) {
                                // Scale with cell width but cap at reasonable maximum
                                const cellBasedSize = gridEntry.width * 0.4;
                                const maxSize = Style.fontSizeXXXL * Style.uiScaleRatio;
                                return Math.min(cellBasedSize, maxSize);
                            }
                            return Style.fontSizeXXL * 2 * Style.uiScaleRatio;
                        }
                        // Scale font size relative to cell width for low res, but cap at maximum
                        const cellBasedSize = gridEntry.width * 0.25;
                        const baseSize = Style.fontSizeXL * Style.uiScaleRatio;
                        const maxSize = Style.fontSizeXXL * Style.uiScaleRatio;
                        return Math.min(Math.max(cellBasedSize, baseSize), maxSize);
                    }
                    font.weight: Style.fontWeightBold
                    color: modelData.displayString ? Colors.md3.on_surface : Colors.md3.on_primary
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

                    Text {
                        anchors.centerIn: parent
                        text: modelData.badgeIcon || ""
                        font.pixelSize: Style.fontSizeS
                        color: Colors.md3.on_surfaceVariant
                    }

                }

            }

            // Text content (hidden when hideLabel is true)
            Text {
                visible: !modelData.hideLabel
                text: modelData.name || "Unknown"
                font.pixelSize: {
                    if (launcher.providerHasDisplayString && modelData.displayString)
                        return Style.fontSizeS * Style.uiScaleRatio;

                    // Scale font size relative to cell width for low res, but cap at maximum
                    const cellBasedSize = gridEntry.width * 0.1;
                    const baseSize = Style.fontSizeXS * Style.uiScaleRatio;
                    const maxSize = Style.fontSizeS * Style.uiScaleRatio;
                    return Math.min(Math.max(cellBasedSize, baseSize), maxSize);
                }
                font.weight: Style.fontWeightSemiBold
                color: gridEntryContainer.isSelected ? Colors.md3.tertiary : Colors.md3.on_surface
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.maximumWidth: gridEntry.width - 8
                Layout.leftMargin: (launcher.providerHasDisplayString && modelData.displayString) ? Style.marginS : 0
                Layout.rightMargin: (launcher.providerHasDisplayString && modelData.displayString) ? Style.marginS : 0
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.NoWrap
                maximumLineCount: 1
            }

        }

        // Action buttons (overlay in top-right corner) - dynamically populated from provider
        Row {
            property var gridItemActions: {
                if (!gridEntryContainer.isSelected)
                    return [];

                var provider = modelData.provider || launcher.currentProvider;
                if (provider && provider.getItemActions)
                    return provider.getItemActions(modelData);

                return [];
            }

            visible: gridEntryContainer.isSelected && gridItemActions.length > 0
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: Style.marginXS
            z: 10
            spacing: Style.marginXXS

            Repeater {
                model: parent.gridItemActions

                NButton {
                    required property var modelData

                    icon: modelData.icon
                    showIcon: true
                    showLabel: false
                    size: Style.baseWidgetSize * 0.75
                    z: 11
                    onClicked: {
                        if (modelData.action)
                            modelData.action();

                    }
                }

            }

        }

        Behavior on color {
            ColorAnimation {
                duration: Style.animationFast
                easing.type: Easing.OutCirc
            }

        }

    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        z: -1
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        enabled: !Settings.data.appLauncher.ignoreMouseInput
        onEntered: {
            if (!launcher.ignoreMouseHover)
                launcher.selectedIndex = gridEntryContainer.index;

        }
        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                launcher.selectedIndex = gridEntryContainer.index;
                launcher.activate();
                mouse.accepted = true;
            }
        }
        acceptedButtons: Qt.LeftButton
    }

}

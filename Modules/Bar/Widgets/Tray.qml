import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs.Commons
import qs.Services

Item {
    id: root

    property ShellScreen screen
    readonly property var trayItems: SystemTray.items.values
    readonly property int iconSize: 16
    // Trigger re-evaluation when window is registered
    property int popupMenuUpdateTrigger: 0
    // Get shared popup menu window from PanelService (reactive to trigger changes)
    readonly property var popupMenuWindow: {
        // Reference trigger to force re-evaluation
        var popupMenuUpdateTriggerRef = popupMenuUpdateTrigger;
        return PanelService.getPopupMenuWindow(screen);
    }
    readonly property var trayMenu: popupMenuWindow ? popupMenuWindow.trayMenuLoader : null
    property int hoveredItemIndex: -1 // Track hovered item
    // widget properties
    property string section: ""
    property int sectionWidgetIndex: -1

    implicitWidth: repeater.implicitWidth
    implicitHeight: Style.barHeight

    Connections {
        function onPopupMenuWindowRegistered(registeredScreen) {
            if (registeredScreen === screen)
                root.popupMenuUpdateTrigger++;

        }

        target: PanelService
    }

    Row {
        id: row

        property var items: {
            if (SystemTray.items && SystemTray.items.values) {
                var newItems = [];
                for (let i = 0; i < SystemTray.items.values.length; i++) {
                    if (!Config.data.bar.blacklistTrayIds.includes(SystemTray.items.values[i].id))
                        newItems.push(SystemTray.items.values[i]);

                }
                return newItems;
            }
            return [];
        }

        anchors.fill: parent
        spacing: Style.marginS

        Connections {
            // Update width automatically

            function onValuesChanged() {
                root.implicitWidth = row.items.length * iconSize + row.spacing * 2;
            }

            target: SystemTray.items
        }

        Repeater {
            id: repeater

            model: row.items
            implicitHeight: iconSize
            implicitWidth: model.length * iconSize + row.spacing * 2

            delegate: Item {
                id: trayDelegate

                required property var modelData
                required property int index
                readonly property bool isHovered: root.hoveredItemIndex === index

                anchors.verticalCenter: parent.verticalCenter
                visible: modelData
                width: iconSize
                height: iconSize

                // Tooltip anchor representing the visual area (for proper tooltip positioning)
                Item {
                    id: tooltipAnchor

                    width: iconSize
                    height: iconSize
                    x: Style.pixelAlignCenter(parent.width, width)
                    y: Style.pixelAlignCenter(parent.height, height)
                }

                Rectangle {
                    id: hoverIndicator

                    anchors.fill: trayIcon
                    anchors.margins: -Style.marginXXS
                    height: 4
                    color: trayDelegate.isHovered ? Colors.a(Colors.md3.primary, 0.5) : "transparent"
                    radius: Style.radiusXS

                    Behavior on color {
                        ColorAnimation {
                            duration: Style.animationFast
                            easing.type: Easing.OutCubic
                        }

                    }

                }

                Image {
                    id: trayIcon

                    source: modelData.icon
                    visible: {
                        !Config.data.bar.blacklistTrayIds.includes(modelData.id);
                    }
                    height: iconSize
                    width: iconSize
                    layer.enabled: true

                    sourceSize {
                        width: iconSize
                        height: iconSize
                    }

                }

                MouseArea {
                    id: itemMouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    onContainsMouseChanged: {
                        if (containsMouse) {
                            if (popupMenuWindow)
                                popupMenuWindow.close();

                            // TooltipService.show(tooltipAnchor, modelData.tooltipTitle || modelData.name || modelData.id || "Tray Item", BarService.getTooltipDirection(root.screen?.name));
                            root.hoveredItemIndex = trayDelegate.index;
                        } else if (root.hoveredItemIndex === trayDelegate.index) {
                            // TooltipService.hide(tooltipAnchor);
                            root.hoveredItemIndex = -1;
                        }
                    }
                    onClicked: (mouse) => {
                        if (!modelData)
                            return ;

                        if (mouse.button === Qt.LeftButton) {
                            // Close any open menu first
                            if (popupMenuWindow)
                                popupMenuWindow.close();

                            if (!modelData.onlyMenu)
                                modelData.activate();

                        } else if (mouse.button === Qt.MiddleButton) {
                            // Close the menu if it was visible
                            if (popupMenuWindow && popupMenuWindow.visible) {
                                popupMenuWindow.close();
                                return ;
                            }
                            modelData.secondaryActivate && modelData.secondaryActivate();
                        } else if (mouse.button === Qt.RightButton) {
                            // TooltipService.hideImmediately();
                            // Close the menu if it was visible
                            if (popupMenuWindow && popupMenuWindow.visible) {
                                popupMenuWindow.close();
                                return ;
                            }
                            // Close any opened panel
                            if ((PanelService.openedPanel !== null) && !PanelService.openedPanel.isClosing)
                                PanelService.openedPanel.close();

                            if (modelData.hasMenu && modelData.menu && trayMenu && trayMenu.item) {
                                let menuX = 0;
                                let menuY = 0;
                                menuX = (tooltipAnchor.width / 2) - (trayMenu.item.implicitWidth / 2);
                                menuY = tooltipAnchor.height + 2;
                                PanelService.showTrayMenu(root.screen, modelData, trayMenu.item, tooltipAnchor, menuX, menuY, root.section, root.sectionWidgetIndex);
                            }
                        }
                    }
                }

            }

        }

    }

}

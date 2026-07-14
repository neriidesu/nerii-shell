import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services
import qs.Widgets

PopupWindow {
    id: root

    property ShellScreen screen
    property var trayItem: null
    property var anchorItem: null
    property real anchorX
    property real anchorY
    property bool isSubMenu: false
    property string widgetSection: ""
    property int widgetIndex: -1
    // Derive menu from trayItem (only used for non-submenus)
    readonly property QsMenuHandle menu: isSubMenu ? null : (trayItem ? trayItem.menu : null)
    readonly property int menuWidth: 220

    implicitWidth: menuWidth

    // Use the content height of the Flickable for implicit height
    implicitHeight: Math.max(1, Math.min(screen?.height * 0.9, flickable.contentHeight + Style.margin2S))

    // When implicitHeight changes (menu content loads), force anchor recalculation
    onImplicitHeightChanged: {
        if (visible && anchorItem) {
            Qt.callLater(() => {
                anchor.updateAnchor();
            });
        }
    }

    visible: false
    color: "transparent"
    anchor.item: anchorItem
    anchor.rect.x: {
        if (anchorItem && screen) {
            let baseX = anchorX;

            // Calculate position relative to current screen
            let menuScreenX;
            if (isSubMenu && anchorItem.Window && anchorItem.Window.window) {
                const posInPopup = anchorItem.mapToItem(null, 0, 0);
                const parentWindow = anchorItem.Window.window;
                const windowXOnScreen = parentWindow.x - screen.x;
                menuScreenX = windowXOnScreen + posInPopup.x + baseX;
            } else {
                const anchorGlobalPos = anchorItem.mapToItem(null, 0, 0);
                const anchorScreenX = anchorGlobalPos.x;
                menuScreenX = anchorScreenX + baseX;
            }

            const menuRight = menuScreenX + implicitWidth;
            const screenRight = screen.width;
            const menuLeft = menuScreenX;

            
            // Only adjust if menu would clip off screen boundaries
            // Don't adjust if the positioning is intentional (e.g., negative offset for right bar)
            if (menuRight > screenRight && menuLeft < screenRight) {
                // Clipping on right edge - shift left
                const overflow = menuRight - screenRight;
                return baseX - overflow - Style.marginS;
            } else if (menuLeft < 0 && menuRight > 0) {
                // Clipping on left edge - shift right
                return baseX - menuLeft + Style.marginS;
            }

            return baseX;
        }
        return anchorX;
    }
    anchor.rect.y: {
    if (anchorItem && screen) {
        let baseY = anchorY;

        if (!isSubMenu && anchorY >= 0) {
            const barHeight = Style.barHeight;
            baseY = barHeight + Style.marginS;
        }

        // Use a robust way to get screen coordinates
        const posInWindow = anchorItem.mapToItem(null, 0, 0);
        const parentWindow = anchorItem.Window.window;

        // Calculate screen-relative Y of the window
        let windowYOnScreen = (parentWindow && screen) ? (parentWindow.y - screen.y) : 0;

          // Calculate the screen Y of the menu top
        // Use a small guess for height if implicitHeight is 0 to avoid covering the bar on the first frame
        const effectiveHeight = implicitHeight > 0 ? implicitHeight : 200;

        const menuScreenY = windowYOnScreen + posInWindow.y + baseY;
        const menuBottom = menuScreenY + (implicitHeight > 0 ? implicitHeight : effectiveHeight);
        const screenHeight = screen ? screen.height : 1080;


        // Adjust if menu would clip off the bottom
        if (menuBottom > screenHeight) {
            const overflow = menuBottom - screenHeight;
            baseY -= (overflow + Style.marginS);
        }

        // Adjust if menu would clip off the top
        // menuScreenY < 0 means it's above the screen edge
        if (menuScreenY < 0) {
            baseY -= (menuScreenY - Style.marginS);
        }

        return baseY;
    }

    // Fallback if no anchor/screen
    if (isSubMenu) {
        return anchorY;
        }
        return anchorY + Style.barHeight;
    }

    function showAt(item, x,y) {
        if (!item) {
            Logger.w("TrayMenu", "anchorItem is undefined, won't show menu.");
            return;
        }
        if (!opener.children || opener.children.values.length === 0) {
            Qt.callLater(() => showAt(item, x, y));
            return;
        }

        anchorItem = item;
        anchorX = x;
        anchorY = y;

        visible = true;
        forceActiveFocus();
        
        // Force update after showing.
        Qt.callLater(() => {
            root.anchor.updateAnchor();
        });
    }

    function hideMenu() {
        visible = false;

        // Clean up all submenus recursively
        for (var i = 0; i < columnLayout.children.length; i++) {
            const child = columnLayout.children[i];
            if (child?.subMenu) {
                child.subMenu.hideMenu();
                child.subMenu.destroy();
                child.subMenu = null;
            }
        }
    }

    Item {
        anchors.fill: parent
        Keys.onEscapePressed: root.hideMenu()
    }

    QsMenuOpener {
        id: opener
        menu: root.menu
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.md3.surface
        border.color: Colors.md3.primary
        border.width: Style.borderS
        radius: Style.radiusM

        opacity: root.visible ? 1.0: 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: Style.animationNormal
                easing.type: Easing.OutQuad
            }
        }
    }

    Flickable {

        id: flickable
        anchors.fill: parent
        anchors.margins: Style.marginS
        contentHeight: columnLayout.implicitHeight
        interactive: true
        opacity: root.visible ? 1.0: 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: Style.animationNormal
                easing.type: Easing.OutQuad
            }
        }

        ColumnLayout {
            id: columnLayout
            width: flickable.width
            spacing: 0

            Repeater {
                model: opener.children ? [...opener.children.values] : []

                delegate: Rectangle {
                    id: entry
                    required property var modelData

                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: {
                        if (modelData?.isSeparator) {
                            return 8;
                        } else {
                            const textHeight = text.contentHeight || (Style.fontSizeS * 1.2);
                            return Math.max(28, textHeight + Style.margin2S)
                        }
                    }


                    color: "transparent"
                    property var subMenu: null

                    NDivider {
                        anchors.centerIn: parent
                        width: parent.width - Style.margin2M
                        visible: modelData?.isSeparator ?? false
                    }

                    Rectangle {
                        id: innerRect
                        anchors.fill: parent
                        color: mouseArea.containsMouse ? Colors.mOnHover : "transparent"
                        radius: Style.radiusS
                        visible: !(modelData?.isSeparator ?? false)
                        Behavior on color {
                            ColorAnimation {
                                duration: Style.animationFast
                            }
                        }
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Style.marginM
                            anchors.rightMargin: Style.marginM
                            spacing: Style.marginS

                            Item {
                                visible: (modelData?.buttonType ?? QsMenuButtonType.None) !== QsMenuButtonType.None
                                Component.onCompleted: {
                                    visible = (modelData?.buttonType ?? QsMenuButtonType.None) !== QsMenuButtonType.None;
                                }
                                implicitWidth: Math.round(Style.baseWidgetSize * 0.5)
                                implicitHeight: Math.round(Style.baseWidgetSize * 0.5)
                                Layout.alignment: Qt.AlignVCenter

                                readonly property int type: modelData?.buttonType ?? QsMenuButtonType.None
                                readonly property bool isRadio: type === QsMenuButtonType.RadioButton
                                readonly property bool isChecked: modelData?.checkState === Qt.Checked || (modelData?.checked ?? false)

                                readonly property color activeColor: mouseArea.containsMouse ? Colors.mOnHover : Colors.md3.on_background
                                readonly property color checkMarkColor: mouseArea.containsMouse ? Colors.md3.on_background : Colors.md3.primary
                                readonly property color borderColor: isChecked ? activeColor : (mouseArea.containsMouse ? Colors.mOnHover : Colors.md3.on_surface)

                                Rectangle {
                                    visible: !parent.isRadio
                                    anchors.centerIn: parent
                                    width: Math.round(Style.baseWidgetSize * 0.5)
                                    height: Math.round(Style.baseWidgetSize * 0.5)
                                    radius: Style.radiusXS
                                    color: "transparent"
                                    border.color: parent.borderColor
                                    border.width: Style.borderM

                                    Behavior on border.color {
                                        ColorAnimation {
                                            duration: Style.animationFast
                                        }
                                    }

                                    Text {
                                        visible: parent.parent.isChecked
                                        anchors.centerIn: parent
                                        // anchors.horizontalCenterOffset: -1
                                        text: ""
                                        color: parent.parent.activeColor
                                        font.pixelSize: Math.max(Style.fontSizeXXS, parent.width * 0.6)
                                    }
                                }

                                Rectangle {
                                    visible: parent.isRadio
                                    anchors.centerIn: parent
                                    width: Math.round(Style.baseWidgetSize * 0.5)
                                    height: Math.round(Style.baseWidgetSize * 0.5)
                                    radius: Style.radiusXS
                                    color: "transparent"
                                    border.color: parent.borderColor
                                    border.width: Style.borderM

                                    Behavior on border.color {
                                        ColorAnimation {
                                            duration: Style.animationFast
                                        }
                                    }

                                    Rectangle {
                                        visible: parent.parent.isChecked
                                        anchors.centerIn: parent
                                        width: Math.round(parent.width * 0.5)
                                        height: Math.round(parent.height * 0.5)
                                        radius: width / 2
                                        color: parent.parent.activeColor

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: Style.animationFast
                                            }
                                        }
                                    }
                                }
                            }

                            Text {
                                id: text
                                Layout.fillWidth: true
                                color: (modelData?.enabled ?? true) ? Colors.md3.on_background : Color.md3.on_surface
                                text: modelData?.text !== "" ? modelData?.text.replace(/[\n\r]+/g, ' ') : "..."
                                font.pixelSize: Style.fontSizeS
                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.WordWrap
                            }

                            Image {
                                Layout.preferredWidth: Style.marginL
                                Layout.preferredHeight: Style.marginL
                                source: modelData?.icon ?? ""
                                visible: (modelData?.icon ?? "") !== ""
                                fillMode: Image.PreserveAspectFit
                            }

                            Text {
                                text: modelData?.hasChildren ? "󰍜" : ""
                                font.pixelSize: Style.fontSizeS
                                verticalAlignment: Text.AlignVCenter
                                visible: modelData?.hasChildren ?? false
                                color: (mouseArea.containsMouse ? Colors.md3.tertiary : Colors.md3.on_background)
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: (modelData?.enabled ?? true) && !(modelData?.isSeparator ?? false) && root.visible
                            acceptedButtons: Qt.LeftButton | Qt.RightButton

                            onClicked: mouse => {
                                if (modelData && !modelData.isSeparator) {
                                    if(modelData.hasChildren) {
                                        if (entry.subMenu) {
                                            entry.subMenu.hideMenu();
                                            entry.subMenu.destroy();
                                            entry.subMenu = null;
                                        } else {
                                            for (var i = 0; i < columnLayout.children.length; i++) {
                                                const sibling = columnLayout.children[i];
                                                if (sibling !== entry && sibling.subMenu) {
                                                    sibling.subMenu.hideMenu();
                                                    sibling.subMenu.destroy();
                                                    sibling.subMenu = null;
                                                }
                                            }

                                            let openLeft = false;
                                            const globalPos = entry.mapToItem(null, 0, 0);

                                            openLeft = (root.widgetSection === "right");

                                            entry.subMenu = Qt.createComponent("TrayMenu.qml").createObject(root, {
                                                "menu": modelData,
                                                "isSubMenu": true,
                                                "screen": root.screen
                                            });

                                            if (entry.subMenu) {
                                                const overlap = 60;
                                                entry.subMenu.anchorItem = entry;
                                                entry.subMenu.anchorX = openLeft ? -overlap : overlap;
                                                entry.subMenu.anchorY = 0;
                                                entry.subMenu.visible = true;
                                                // Force anchor update with new position
                                                Qt.callLater(() => {
                                                    entry.subMenu.anchor.updateAnchor();
                                                });
                                            }
                                        }
                                    } else {
                                        modelData.triggered();
                                        // root.hideMenu();
                                    }
                                }
                            }
                        }
                    }

                    Component.onDestruction: {
                        if (subMenu) {
                            subMenu.destroy();
                            subMenu = null;
                        }
                    }
                }
            }
        }
    }

}

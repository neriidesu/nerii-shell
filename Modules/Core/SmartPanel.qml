import QtQuick
import QtQuick.Shapes
import Quickshell
import qs.Commons
import qs.Services

/**
* SmartPanel for use within PanelContainer
*/
Item {
    id: root
    // Screen property
    property ShellScreen screen: null
    // Panel content: Text, icons, etc...
    property Component panelContent: null
    // Panel size properties
    property real preferredWidth: 700
    property real preferredHeight: 900
    // Panel State
    property bool isPanelOpen: false
    property bool isPanelVisible: true
    property bool isClosing: false
    property bool closeFinalized: false
    property point targetPosition: Qt.point(0,0)
    property point startingPosition: Qt.point(0,0)
    // Panel Position
    property bool isConnected
    property bool useImplicitPosition: false
    property int implicitX: 0
    property int implictY: 0
    property string horizontalPosition: "center"
    property string verticalPosition: "top"
    property bool useButtonPosition: false
    property point buttonPosition: Qt.point(0, 0)
    property int buttonWidth: 0
    property int buttonHeight: 0
    property var buttonItem: null
    // Colors
    property color panelBackgroundColor: Style.cPanelBackground
    property color panelBorderColor: Colors.md3.primary
    // Panel Settings
    property bool closeWithEscape: true
    property bool showBorders: Style.showPanelBorders
    // Shortcuts
    property real barMargin: Style.barMargin
    property real barHeight: Style.barHeight
    property bool allowPanelConnect: Style.allowPanelConnect
    property real topGap: Style.topGap
    property real bottomGap: Style.bottomGap

    clip: true

    signal opened()
    signal closed()

    function onEscapePressed() {
        if (closeWithEscape)
            close();

    }

    // Panel control functions
    function toggle(buttonItem) {
        if (!isPanelOpen)
            open(buttonItem);
        else
            close();
    }

    function open(buttonItem) {
        // Reset immediate close flag to ensure animations work properly
        PanelService.closedImmediately = false;
        // Reset to default - fixes panel being stuck in one position
        root.useButtonPosition = false;
        var barWindowX = root.barMargin;
        var barWindowY = root.barMargin;
        // Validate buttonItem is a valid QML Item with mapToItem function
        if (buttonItem && typeof buttonItem.mapToItem === "function") {
            try {
                root.buttonItem = buttonItem;
                // Map button position within its window (BarContentWindow-local coordinates)
                var buttonLocal = buttonItem.mapToItem(null, 0, 0);
                root.buttonPosition = Qt.point(barWindowX + buttonLocal.x, barWindowY + buttonLocal.y);
                root.buttonWidth = buttonItem.width;
                root.buttonHeight = buttonItem.height;
                root.useButtonPosition = true;
            } catch (e) {
                Logger.w("SmartPanel", "Failed to get button position, using default positioning:", e);
                root.buttonItem = null;
                root.useButtonPosition = false;
            }
        } else if (!root.useButtonPosition) {
            // No valid button provided and no click position: reset button position mode
            root.buttonItem = null;
        }
        isPanelOpen = true;
        PanelService.willOpenPanel(root);
        panelBackground.opacity = 0
        opened();
    }

    function close() {
        // Reset immediate close flag to ensure animations work properly
        PanelService.closedImmediately = false;
        isClosing = true;
        closeFinalized = false;
        closeAnim.start()
    }

    function closeImmediately() {
        isPanelVisible = false;
        isPanelOpen = false;
        closed();
        PanelService.closedImmediately = true;
        PanelService.closedPanel(root);
        Logger.d("SmartPanel", "Panel closed immediately", objectName);
    }

    function finalizeClose() {
        // Prevent double-finalization
        if (root.closeFinalized) {
            Logger.w("SmartPanel", "finalizeClose called but already finalized - ignoring", objectName);
            return;
        }

        // Complete the close sequence after animations finish
        root.closeFinalized = true;

        root.isPanelVisible = false;
        root.isPanelOpen = false;
        root.isClosing = false;

        PanelService.closedPanel(root);
        closed();

        // Flush pending double-buffered Wayland state (blur regions).
        Window.window?.flushWaylandState();

        Logger.d("SmartPanel", "Panel close finalized", objectName);
    }

    function setPosition() {
        if (useImplicitPosition) {
            panelBackground.x = implicitX / 2;
            panelBackground.y = implicitY / 2;
            startingPosition.x = panelBackground.x
            startingPosition.y = panelBackground.y
            targetPosition = startingPosition
            return ;
        }
        var calculatedX = 0;
        var calculatedY = 0;
        switch (horizontalPosition) {
        case "left":
            calculatedX = 0;
            startingPosition.x = 0;
            break;
        case "center":
            calculatedX = (screen.width - panelBackground.width) / 2;
            startingPosition.x = screen.width / 4;
            break;
        case "right":
            calculatedX = screen.width - panelBackground.width;
            startingPosition.x = (screen.width - panelBackground.width) / 4;
            break;
        }
        switch (verticalPosition) {
        case "top":
            if (allowPanelConnect) {
                isConnected = true
                calculatedY = -topGap - 3;
                startingPosition.y = -topGap - 3;
            } else {
                calculatedY = 0;
                startingPosition.y = 0;
            }
            break;
        case "center":
            calculatedY = (screen.height - barHeight - (barMargin * 3) - panelBackground.height - 6) / 2;
            startingPosition.y = (screen.height - barHeight - (barMargin * 3) + 6) / 4
            break;
        case "bottom":
            calculatedY = screen.height - barHeight - barMargin - topGap - bottomGap - panelBackground.height - (bottomGap /2);
            startingPosition.y = (screen.height - barHeight - barMargin - topGap - bottomGap + (bottomGap /2)) / 2;
            break;
        }
        if (useButtonPosition) {
            calculatedX = buttonPosition.x + buttonWidth / 2 - panelBackground.width / 2;
            startingPosition.x = (buttonPosition.x + buttonWidth / 2) / 2;
            if (allowPanelConnect) {
                isConnected = true
                calculatedY = -topGap - 3;
                startingPosition.y = -topGap - 3;
            } else {
                calculatedY = 0;
                startingPosition.y = 0;
            }
        }
        startingPosition.x = Math.min(Math.max(startingPosition.x, barMargin/2),(screen.width - panelBackground.width - barMargin) / 2)
        panelBackground.x = Math.min(Math.max(calculatedX / 2,barMargin/2),(screen.width - panelBackground.width - barMargin) / 2);
        panelBackground.y = (calculatedY + Style.marginL) / 2;
        targetPosition.x = panelBackground.x
        targetPosition.y = panelBackground.y
    }

    visible: true
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    Component.onCompleted: {
        PanelService.registerPanel(root);
    }

    // Watch for changes in content-driven sizes and update position
    Connections {
        function onContentPreferredWidthChanged() {
            if (root.isPanelOpen && root.isPanelVisible)
                root.setPosition();

        }

        function onContentPreferredHeightChanged() {
            if (root.isPanelOpen && root.isPanelVisible)
                root.setPosition();

        }

        target: contentLoader.item
        ignoreUnknownSignals: true
    }

    // ------------------------------------------------
    // Panel Content
    Item {
        id: panelContent

        anchors.fill: parent

        Item {
            id: panelBackground

            visible: isPanelVisible
            property var targetHeight: contentLoader.active ? contentLoader.item.contentPreferredHeight : 0
            property var targetWidth: contentLoader.active ? contentLoader.item.contentPreferredWidth : 0
            implicitWidth: targetWidth
            implicitHeight: targetHeight

            Loader {
                id: contentLoader

                active: isPanelOpen
                x: panelBackground.x
                y: panelBackground.y
                width: panelBackground.width
                height: panelBackground.height
                sourceComponent: root.panelContent
                onLoaded: {
                    Qt.callLater(() => {
                        setPosition();
                        root.isPanelVisible = true;
                        openAnim.start()
                    });
                }
            }

            Loader {
                active: isPanelOpen && allowPanelConnect
                anchors.fill: parent

                sourceComponent: Item {
                    anchors.fill: parent
                    visible: isPanelOpen
                    Shape {
                        width: Style.radiusL
                        height: Style.radiusL
                        x: targetPosition.x
                        y: targetPosition.y
                        ShapePath {
                            fillColor: panelBackgroundColor
                            strokeWidth: 0
                            PathLine {
                                relativeX: -Style.radiusL
                                relativeY: 0
                            }
                            PathArc {
                                relativeX: Style.radiusL
                                relativeY: Style.radiusL
                                radiusX: Style.radiusL
                                radiusY: Style.radiusL
                            }
                            PathLine {
                                relativeX: 0
                                relativeY: -Style.radiusL
                            }
                        }
                    }
                    Shape {
                        width: Style.radiusL
                        height: Style.radiusL
                        x: targetPosition.x + (panelBackground.width)
                        y: targetPosition.y
                        ShapePath {
                            fillColor: panelBackgroundColor
                            strokeWidth: 0
                            PathLine {
                                relativeX: 0
                                relativeY: Style.radiusL
                            }
                            PathArc {
                                relativeX: Style.radiusL
                                relativeY: -Style.radiusL
                                radiusX: Style.radiusL
                                radiusY: Style.radiusL
                            }
                            PathLine {
                                relativeX: Style.radiusL
                                relativeY: 0
                            }
                        }
                    }
                }
            }
        }
    }

    ParallelAnimation{
                id: closeAnim
                NumberAnimation {
                    target: panelBackground; property: "opacity"
                    from: 1; to: 0
                    duration: Style.animationNormal
                }
                NumberAnimation {
                    target: panelBackground; property: "implicitHeight"
                    from: panelBackground.targetHeight; to: 0
                    duration: Style.animationFast; easing: Easing.InQuad
                }
                NumberAnimation {
                    target: panelBackground; property: "y"
                    from: targetPosition.y; to: startingPosition.y
                    duration: Style.animationFast; easing: Easing.InQuad
                }

                onFinished: {
                    finalizeClose()
                }
            }
    ParallelAnimation{
                id: openAnim
                NumberAnimation {
                    target: panelBackground; property: "opacity"
                    from: 0; to: 1
                    duration: Style.animationNormal
                }
                NumberAnimation {
                    target: panelBackground; property: "implicitHeight"
                    from: 0; to: panelBackground.targetHeight
                    duration: Style.animationFast; easing: Easing.OutQuad
                }
                NumberAnimation {
                    target: panelBackground; property: "y"
                    from: startingPosition.y; to: targetPosition.y
                    duration: Style.animationFast; easing: Easing.OutQuad
                }
                

                onFinished: {
                    opened()
                }
            }

}

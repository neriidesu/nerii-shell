import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons

Item {
    id: root

    property bool isHovered: false
    property bool isPressed: false
    // display config
    property int size: 32
    property bool showImage: false
    property var imageSource: ""
    property bool showIcon: false
    property bool actuallyShowIcon: {
        if (showImage && showIcon) {
            Logger.d("NButton", "Can't show both image and icon, prioritizing image.");
            return false;
        }
        return showIcon;
    }
    property string icon: ""
    property bool showLabel: true
    property string label: "PLACEHOLDER"
    // colors
    property string hoverColor: Colors.md3.tertiary

    signal clicked()

    Rectangle {
        id: button

        anchors.fill: parent
        color: Colors.md3.surface_container
        radius: Style.radiusL

        border {
            color: isHovered ? hoverColor : Colors.md3.primary
            width: Style.borderM
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Style.marginS

            Image {
                id: image

                visible: showImage
                horizontalAlignment: Image.AlignHCenter
                source: root.imageSource
                Layout.preferredWidth: parent.width
                fillMode: Image.PreserveAspectFit

                sourceSize {
                    width: size
                    height: size
                }

            }

            Text {
                id: icon

                visible: actuallyShowIcon
                text: root.icon
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: parent.width
                color: root.isHovered ? hoverColor : Colors.md3.on_background

                font {
                    pixelSize: root.size
                    weight: Style.fontWeightBold
                }

            }

            Text {
                id: text

                visible: showLabel
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: parent.width
                wrapMode: Text.Wrap
                text: label
                color: root.isHovered ? hoverColor : Colors.md3.on_background
            }

        }

    }

    Rectangle {
        id: pressIndicator

        anchors.fill: parent
        color: isPressed ? Colors.a(Colors.md3.on_surface, 0.5) : "transparent"
        radius: button.radius

        Behavior on color {
            ColorAnimation {
                duration: Style.animationFaster
                easing.type: Easing.OutQuad
            }

        }

    }

    Rectangle {
        id: hoverIndicator

        anchors.fill: parent
        color: isHovered ? Colors.a(hoverColor, 0.2) : "transparent"
        radius: button.radius

        Behavior on color {
            ColorAnimation {
                duration: Style.animationFaster
                easing.type: Easing.OutQuad
            }

        }

    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            isHovered = true;
        }
        onExited: {
            isHovered = false;
        }
        onPressed: {
            isPressed = true;
        }
        onReleased: {
            isPressed = false;
        }
        onClicked: {
            root.clicked();
        }
    }

}

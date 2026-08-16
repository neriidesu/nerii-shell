import QtQuick
import QtQuick.Effects
import Quickshell

Item {
    id: root

    property bool cache: true
    property int fillMode: Image.PreserveAspectCrop
    property string source: ""
    property int sourceWidth: 0
    property int sourceHeight: 0
    readonly property Item imageSource: img
    property real borderWidth: 0
    property color borderColor: "transparent"
    property bool rounded: true
    property real radius: 0
    readonly property var status: img.status

    layer.enabled: rounded

    Image {
        id: img

        anchors.fill: root
        anchors.margins: root.borderWidth
        asynchronous: true
        cache: root.cache
        fillMode: root.fillMode
        source: root.source
        sourceSize.width: sourceWidth
        sourceSize.height: sourceHeight
        visible: false
    }

    MultiEffect {
        source: img
        anchors.fill: img
        maskEnabled: true
        maskSource: mask
    }

    Item {
        id: mask

        width: img.width
        height: img.height
        layer.enabled: true
        visible: false

        Rectangle {
            width: img.width
            height: img.height
            radius: root.radius
            color: "black"
        }

    }

}

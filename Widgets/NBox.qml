// Rounded group container using the variant surface color.
// To be used in side panels and settings panes to group fields or buttons.
// Opacity is based on panelBackgroundOpacity but clamped to a minimum to avoid full transparency.

import QtQuick
import qs.Commons

Item {
    id: root

    property color color: Colors.md3.surface_variant
    property alias radius: bg.radius
    property alias border: bg.border

    Rectangle {
        id: bg

        anchors.fill: parent
        radius: Style.radiusM
        border.color: Colors.md3.primary
        border.width: Style.borderS
        color: root.color
    }

}

import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.Commons

Rectangle {
    property bool vertical: false

    width: vertical ? Style.borderS : parent.width
    height: vertical ? parent.height : Style.borderS

    gradient: Gradient {
        orientation: vertical ? Gradient.Vertical : Gradient.Horizontal

        GradientStop {
            position: 0
            color: "transparent"
        }

        GradientStop {
            position: 0.1
            color: Colors.md3.primary
        }

        GradientStop {
            position: 0.9
            color: Colors.md3.primary
        }

        GradientStop {
            position: 1
            color: "transparent"
        }

    }

}

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Modules.Bar.Widgets

RowLayout {
    id: left_modules

    BarGroup {
        Separator {
            type: -1
        }

        Workspaces {
        }

        Separator {
            type: 1
        }

    }

}

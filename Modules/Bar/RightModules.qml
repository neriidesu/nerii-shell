import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Modules.Bar.Widgets

RowLayout {
    id: right_modules

    BarGroup {
        Separator {
            type: -1
        }

        Network {
        }

        Separator {
        }

        Volume {
        }

        Separator {
        }

        Tray {
        }

        Separator {
        }

        Battery {
            visible: Config.showBattery
        }

        Separator {
            visible: Config.showBattery
        }

        Clock {
        }

        Separator {
            type: 1
        }

    }

}

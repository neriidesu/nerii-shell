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

        Volume {
        }

        Separator {
        }

        Network {
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

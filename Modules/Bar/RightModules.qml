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

        Weather {
        }

        Separator {
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
            screen: bar_root.screen
        }

        Separator {
        }

        Battery {
            visible: Config.data.bar.showBattery
        }

        Separator {
            visible: Config.data.bar.showBattery
        }

        Clock {
        }

        Separator {
            type: 1
        }

    }

}

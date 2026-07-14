import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Modules.Bar.Widgets
import qs.Services

RowLayout {
    id: left_modules

    BarGroup {
        Separator {
            type: -1
        }

        Workspaces {
        }

        Separator {
            visible: MediaService.currentPlayer
        }

        Media {
            visible: MediaService.currentPlayer
        }

        Separator {
            type: 1
        }

    }

}

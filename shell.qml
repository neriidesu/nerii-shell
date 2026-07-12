import Quickshell
import qs.Commons
import qs.Modules.Bar

ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData

            screen: modelData
        }

    }

}

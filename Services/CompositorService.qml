import Quickshell
import Quickshell.Hyprland
pragma Singleton

Singleton {
    id: root

    function lock() {
        // custom lockservice?
        Quickshell.execDetached(["sh", "-c", "hyprlock"]);
    }

    function hibernate() {
        Quickshell.execDetached(["sh", "-c", "systemctl sleep"]);
    }

    function reboot() {
        Quickshell.execDetached(["sh", "-c", "systemctl reboot"]);
    }

    function logout() {
        Quickshell.execDetached(["sh", "-c", "hyprctl dispatch exit"]);
    }

    function shutdown() {
        Quickshell.execDetached(["sh", "-c", "systemctl poweroff"]);
    }

    // Get focused screen from compositor
    function getFocusedScreen() {
        const hyprMon = Hyprland.focusedMonitor;
        if (hyprMon) {
            const monitorName = hyprMon.name;
            for (let i = 0; i < Quickshell.screens.length; i++) {
                if (Quickshell.screens[i].name === monitorName)
                    return Quickshell.screens[i];

            }
        }
        return null;
    }

}

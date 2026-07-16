import Quickshell
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

}

import Quickshell
import Quickshell.Hyprland
import qs.Commons
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

    function spawn(command) {
        try {
            const cmd = command instanceof Array ? command.join(" ") : String(command);
            dispatchCommand(`hl.dsp.exec_cmd("${luaQuote(cmd)}")`);
        } catch (e) {
            Logger.e("CompositorService", "Failed to spawn command:", e);
        }
    }

    // Dispatch helpers
    function luaQuote(str) {
        return String(str).replace(/\\/g, "\\\\").replace(/"/g, "\\\"").replace(/\n/g, "\\n").replace(/\r/g, "\\r");
    }

    function dispatchCommand(luaCommand) {
        Logger.d("CompositorService", "Dispatch (Lua):", luaCommand);
        Quickshell.execDetached(["hyprctl", "dispatch", luaCommand]);
    }

}

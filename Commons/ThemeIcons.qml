import QtQuick
import Quickshell
import qs.Commons
pragma Singleton

Singleton {
    id: root

    function iconFromName(iconName, fallbackName) {
        const fallback = fallbackName || "application-x-executable";
        try {
            if (iconName && typeof Quickshell !== 'undefined' && Quickshell.iconPath) {
                const p = Quickshell.iconPath(iconName, fallback);
                if (p && p !== "")
                    return p;

            }
        } catch (e) {
        }
        try {
            return Quickshell.iconPath ? (Quickshell.iconPath(fallback, true) || "") : "";
        } catch (e2) {
            return "";
        }
    }

}

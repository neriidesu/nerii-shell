import QtQuick
import Quickshell
import qs.Commons
pragma Singleton

Singleton {
    id: root

    function iconFromName(iconName, fallbackName) {
        const fallback = fallbackName || "folder";
        if (!iconName)
            return Quickshell.iconPath(fallback);

        return Quickshell.iconPath(iconName, fallback);
    }

}

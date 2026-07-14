import QtQuick
import Quickshell
pragma Singleton

Singleton {
    property real barMargin: 10
    property bool directoriesCreated: false
    readonly property string shellName: "nerii-shell"
    readonly property string cacheDir: ensureTrailingSlash((Quickshell.env("XDG_CACHE_HOME") || (Quickshell.env("HOME") + "/" + ".cache") + "/" + shellName + "/"))
    property bool showBattery: false
    property bool showWifi: false
    property bool showEth: true
    property bool debug: true
    property var keepWorkspaces: {
        "DP-2": [1, 10],
        "DP-3": [2, 3, 4]
    }
    property var blacklistTrayIds: ["spotify-client"]
    property var preferredPlayer: "spotify"
    property string locationName: "Mölndal,Sweden"
    property bool updateWeather: true

    // Preprocess paths by adding trailing "/"
    function ensureTrailingSlash(path) {
        return path.endsWith("/") ? path : path + "/";
    }

    Component.onCompleted: {
        Quickshell.execDetached(["mkdir", "-p", cacheDir]);
    }
}

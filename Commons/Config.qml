import Quickshell
pragma Singleton

Singleton {
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
}

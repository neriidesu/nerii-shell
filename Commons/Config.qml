import Quickshell
pragma Singleton

Singleton {
    property bool showBattery: false
    property bool showWifi: false
    property bool showEth: true
    property bool debug: true
    property var keepWorkspaces: [1, 2, 3, 4, 10]
    property var blacklistTrayIds: ["spotify-client"]
    property var preferredPlayer: "spotify"
}

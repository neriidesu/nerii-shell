import "../Helpers/QtObj2JS.js" as QtObj2JS
import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    readonly property alias data: adapter
    readonly property alias configFileView: configFileView
    property bool directoriesCreated: false
    property bool reloadConfig: false
    property bool isLoaded: false
    readonly property int configVersion: 0
    readonly property string shellName: "nerii-shell"
    readonly property string cacheDir: ensureTrailingSlash((Quickshell.env("XDG_CACHE_HOME") || (Quickshell.env("HOME") + "/" + ".cache") + "/" + shellName + "/"))
    readonly property string configDir: ensureTrailingSlash((Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/" + ".config") + "/" + shellName + "/"))
    readonly property string configFile: configDir + "config.json"
    property bool panelsAttachedToBar: true
    property bool animationsDisabled: false
    // Cached default config object
    property var _defaultConfig: null

    signal configLoaded()
    signal configReloaded()
    signal configSaved()

    // Preprocess paths by adding trailing "/"
    function ensureTrailingSlash(path) {
        return path.endsWith("/") ? path : path + "/";
    }

    function saveImmediate() {
        configFileView.writeAdapter();
        root.configSaved();
    }

    function scheduleExternalReload() {
        if (!directoriesCreated || configFileView.path === undefined)
            return ;

        externalReloadTimer.restart();
    }

    // Generate default config: for reference only, not used by the shell
    function generateDefaultConfig() {
        try {
            Logger.d("Config", "Generating config-default.json");
            // Prepare a clean JSON
            var plainAdapter = QtObj2JS.qtObjectToPlainObject(adapter);
            var jsonData = JSON.stringify(plainAdapter, null, 2);
            var defaultPath = Quickshell.shellDir + "/Assets/config-default.json";
            Quickshell.execDetached(["sh", "-c", `cat > "${defaultPath}" << 'NS_EOF'\n${jsonData}\nNS_EOF`]);
        } catch (error) {
            Logger.e("Config", "Failed to generate default config file: " + error);
        }
    }

    Component.onCompleted: {
        Quickshell.execDetached(["mkdir", "-p", cacheDir]);
        Quickshell.execDetached(["mkdir", "-p", configDir]);
        directoriesCreated = true;
        // generateDefaultConfig();
        configFileView.adapter = adapter;
    }

    Timer {
        id: saveTimer

        running: false
        interval: 500
        onTriggered: {
            root.saveImmediate();
        }
    }

    FileView {
        id: configFileView

        path: directoriesCreated ? configFile : undefined
        printErrors: false
        watchChanges: true
        onAdapterUpdated: saveTimer.start()
        onFileChanged: scheduleExternalReload()
        onPathChanged: {
            if (path !== undefined)
                reload();

        }
        onLoaded: function() {
            if (!isLoaded) {
                Logger.i("Config", "Config Loaded");
                // var rawJson = null;
                // try {
                //     rawJson = JSON.parse(configFileView.text());
                // } catch (e) {
                //     Logger.w("Config", "Could not parse raw JSON for migrations");
                // }
                // runVersionedMigrations(rawJson);
                // adapter.configVersion = configVersion;
                root.isLoaded = true;
                root.configLoaded();
            } else {
                Logger.d("Config", "Config reloaded from external file change");
                root.configReloaded();
            }
        }
        onLoadFailed: function(error) {
            if (reloadConfig) {
                reloadConfig = false;
                return ;
            }
            if (error.toString().includes("No such file") || error === 2)
                writeAdapter();

        }
    }

    FileView {
        id: configDirWatcher

        path: directoriesCreated ? configDir : undefined
        printErrors: false
        watchChanges: true
        onFileChanged: scheduleExternalReload()
    }

    FileView {
        id: defaultConfigFileView

        path: Quickshell.shellDir + "/Assets/config-default.json"
        printErrors: false
        watchChanges: false
    }

    Connections {
        function onLoaded() {
            try {
                root._defaultConfig = JSON.parse(defaultConfigFileView.text());
            } catch (e) {
                Logger.w("Config", "Failed to parse default config file: " + e);
                root._defaultConfig = null;
            }
        }

        target: defaultConfigFileView
    }

    Timer {
        id: externalReloadTimer

        running: false
        interval: 200
        onTriggered: {
            if (configFileView.path !== undefined) {
                Logger.d("Config", "Reloading config after external change detection");
                reloadConfig = true;
                configFileView.reload();
            }
        }
    }

    JsonAdapter {
        id: adapter

        property int configVersion: 0
        property JsonObject misc
        property JsonObject bar
        property JsonObject media
        property JsonObject weather
        property JsonObject wallpaper
        property JsonObject appLauncher
        property JsonObject colors

        misc: JsonObject {
            property bool debug: false
            property string theme: ""
        }

        colors: JsonObject {
            property bool genFromWallpaper: true
            property bool genFromColor: false
            property bool genWithTheme: false
            property string themeName: ""
            property string themeDir: ""
            property string primaryHex: ""
        }

        bar: JsonObject {
            property bool showBattery: true
            property bool showWifi: true
            property bool showEth: true
            property var keepWorkspaces: {
            }
            property var blacklistTrayIds: []
        }

        media: JsonObject {
            property var preferredPlayer: ""
        }

        weather: JsonObject {
            property string locationName: ""
            property bool updateWeather: true
        }

        wallpaper: JsonObject {
            property string wallpaperPath: ""
            property string wallpaperDir: ""
            property string lweDir: ""
            property bool enableLwe: false
        }

        appLauncher: JsonObject {
            property string terminalCommand: "kitty"
            // Icon mode: "tabler" or "native"
            property string iconMode: "tabler"
        }

    }

}

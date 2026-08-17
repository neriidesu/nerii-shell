import "../Helpers/QtObj2JS.js" as QtObj2JS
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services
pragma Singleton

// Centralized shell state management for small cache files
// Forked from noctalia-v4 (https://github.com/noctalia-dev/noctalia/tree/legacy-v4)
Singleton {
    id: root

    property string stateFile: ""
    property bool isLoaded: false
    // State properties for different services
    readonly property alias data: adapter
    property bool saveQueued: false

    // Launcher usage
    function getLauncherUsageCount(key) {
        const m = adapter.launcherUsage;
        if (!m)
            return 0;

        const v = m[key];
        return typeof v === 'number' && isFinite(v) ? v : 0;
    }

    function recordLauncherUsage(key) {
        let counts = Object.assign({
        }, adapter.launcherUsage || {
        });
        counts[key] = getLauncherUsageCount(key) + 1;
        adapter.launcherUsage = counts;
        save();
    }

    // Migrate usage from one key to another, merging counts in a single save
    function migrateLauncherUsage(fromKey, toKey) {
        let counts = Object.assign({
        }, adapter.launcherUsage || {
        });
        const fromCount = typeof counts[fromKey] === 'number' && isFinite(counts[fromKey]) ? counts[fromKey] : 0;
        const toCount = typeof counts[toKey] === 'number' && isFinite(counts[toKey]) ? counts[toKey] : 0;
        counts[toKey] = toCount + fromCount;
        delete counts[fromKey];
        adapter.launcherUsage = counts;
        save();
    }

    function save() {
        saveQueued = true;
        saveTimer.restart();
    }

    function performSave() {
        if (!saveQueued || !stateFile)
            return ;

        saveQueued = false;
        try {
            // Ensure cache directory exists
            Quickshell.execDetached(["mkdir", "-p", Config.cacheDir]);
            Qt.callLater(() => {
                try {
                    stateFileView.writeAdapter();
                    Logger.d("ShellState", "Saved state file");
                } catch (writeError) {
                    Logger.e("ShellState", "Failed to write state file:", writeError);
                }
            });
        } catch (error) {
            Logger.e("ShellState", "Failed to save state:", error);
        }
    }

    Component.onCompleted: {
        // Setup state file path (needs Config to be available)
        Qt.callLater(() => {
            if (typeof Config !== 'undefined' && Config.cacheDir) {
                stateFile = Config.cacheDir + "shell-state.json";
                stateFileView.path = stateFile;
            }
        });
    }

    FileView {
        id: stateFileView

        printErrors: false
        watchChanges: false
        onLoaded: {
            root.isLoaded = true;
            Logger.d("ShellState", "Loaded state file");
        }
        onLoadFailed: (error) => {
            if (error === 2) {
                // File doesn't exist, will be created on first write
                root.isLoaded = true;
                Logger.d("ShellState", "State file doesn't exist, will create on first write");
            } else {
                Logger.e("ShellState", "Failed to load state file:", error);
                root.isLoaded = true;
            }
        }

        adapter: JsonAdapter {
            id: adapter

            // Launcher app usage counts
            property var launcherUsage: ({
            })
        }

    }

    // Debounced save timer
    Timer {
        id: saveTimer

        interval: 500
        onTriggered: performSave()
    }

}

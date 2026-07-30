import QtQuick
import Quickshell
import qs.Commons
import qs.Services

Item {
    id: root

    property var launcher: null
    property string name: "Applications"
    property bool handleSearch: true
    property var entries: []
    property string supportedLayouts: "both"
    property bool isDefaultProvider: true
    property bool trackUsage: true // Track usage frequency for "most used" sorting

    function init() {
        loadApplications();
        migrateLegacyUsageKeys();
    }

    // Helper function to normalize app IDs for case-insensitive matching
    function normalizeAppId(appId) {
        if (!appId || typeof appId !== 'string')
            return "";

        return appId.toLowerCase().trim();
    }

    function loadApplications() {
        if (typeof DesktopEntries === 'undefined') {
            Logger.w("ApplicationsProvider", "DesktopEntries service not available");
            return ;
        }
        const allApps = DesktopEntries.applications.values || [];
        const seen = new Map(); // Map of appId -> exec command
        entries = allApps.filter((app) => {
            if (!app || app.noDisplay || app.hidden)
                return false;

            const appId = app.id || app.name;
            const execCmd = getExecutableName(app);
            // Check if we've seen this app ID before
            if (seen.has(appId)) {
                const previousExec = seen.get(appId);
                // If exec is different, it's a legitimate different entry - keep it
                if (previousExec !== execCmd) {
                    Logger.d("ApplicationsProvider", `Keeping variant of ${appId}: ${execCmd} (differs from ${previousExec})`);
                    // Add with modified ID to make it unique
                    app.id = `${appId}_${execCmd}`;
                    seen.set(app.id, execCmd);
                    return true;
                }
                // Same appId AND same exec = true duplicate, skip it
                Logger.d("ApplicationsProvider", `Skipping duplicate: ${appId}`);
                return false;
                Logger.d(event.key);
            }
            seen.set(appId, execCmd);
            return true;
        }).map((app) => {
            app.executableName = getExecutableName(app);
            return app;
        });
        Logger.d("ApplicationsProvider", `Loaded ${entries.length} applications`);
    }

    function getExecutableName(app) {
        if (!app)
            return "";

        // Try to get executable name from command array
        if (app.command && Array.isArray(app.command) && app.command.length > 0) {
            const cmd = app.command[0];
            // Extract just the executable name from the full path
            const parts = cmd.split('/');
            const executable = parts[parts.length - 1];
            // Remove any arguments or parameters
            return executable.split(' ')[0];
        }
        // Try to get from exec property if available
        if (app.exec) {
            const parts = app.exec.split('/');
            const executable = parts[parts.length - 1];
            return executable.split(' ')[0];
        }
        // Fallback to app id (desktop file name without .desktop)
        if (app.id)
            return app.id.replace('.desktop', '');

        return "";
    }

    function getResults(query) {
        if (!entries || entries.length === 0)
            return [];

        // Set category mode based on whether there's a query
        const isSearching = !!(query && query.trim() !== "");
        // Filter by category only when NOT searching
        let filteredEntries = entries;
        if (!query || query.trim() === "") {
            // Return filtered apps, optionally sorted by usage
            let sorted;
            sorted = filteredEntries.slice().sort((a, b) => {
                const ua = getUsageCount(a);
                const ub = getUsageCount(b);
                if (ub !== ua)
                    return ub - ua;

                return (a.name || "").toLowerCase().localeCompare((b.name || "").toLowerCase());
            });
            return sorted.map((app) => {
                return createResultEntry(app);
            });
        }
        // Use fuzzy search if available, fallback to simple search
        if (typeof FuzzySort !== 'undefined') {
            const fuzzyResults = FuzzySort.go(query, filteredEntries, {
                "keys": ["name", "comment", "genericName", "executableName"],
                "limit": 20
            });
            // Sort pinned first within fuzzy results while preserving fuzzysort order otherwise
            const nonPinned = [];
            for (const r of fuzzyResults) {
                const app = r.obj;
                nonPinned.push(r);
            }
            return nonPinned.map((result) => {
                return createResultEntry(result.obj, result.score);
            });
        } else {
            // Fallback to simple search
            const searchTerm = query.toLowerCase();
            return filteredEntries.filter((app) => {
                const name = (app.name || "").toLowerCase();
                const comment = (app.comment || "").toLowerCase();
                const generic = (app.genericName || "").toLowerCase();
                const executable = getExecutableName(app).toLowerCase();
                return name.includes(searchTerm) || comment.includes(searchTerm) || generic.includes(searchTerm) || executable.includes(searchTerm);
            }).sort((a, b) => {
                // Prioritize name matches, then executable matches
                const aName = a.name.toLowerCase();
                const bName = b.name.toLowerCase();
                const aExecutable = getExecutableName(a).toLowerCase();
                const bExecutable = getExecutableName(b).toLowerCase();
                const aStarts = aName.startsWith(searchTerm);
                const bStarts = bName.startsWith(searchTerm);
                const aExecStarts = aExecutable.startsWith(searchTerm);
                const bExecStarts = bExecutable.startsWith(searchTerm);
                // Prioritize name matches first
                if (aStarts && !bStarts)
                    return -1;

                if (!aStarts && bStarts)
                    return 1;

                // Then prioritize executable matches
                if (aExecStarts && !bExecStarts)
                    return -1;

                if (!aExecStarts && bExecStarts)
                    return 1;

                return aName.localeCompare(bName);
            }).slice(0, 20).map((app) => {
                return createResultEntry(app);
            });
        }
    }

    function createResultEntry(app, score) {
        return {
            "appId": getAppKey(app),
            "usageKey": getAppKey(app),
            "name": app.name || "Unknown",
            "description": app.genericName || app.comment || "",
            "icon": app.icon || "application-x-executable",
            "isImage": false,
            "_score": (score !== undefined ? score : 0),
            "provider": root,
            "onActivate": function() {
                // Close the launcher/SmartPanel immediately without any animations.
                // Ensures we are not preventing the future focusing of the app
                launcher.closeImmediately();
                // Defer execution to next event loop iteration to ensure panel is fully closed
                Qt.callLater(() => {
                    Logger.d("ApplicationsProvider", `Launching: ${app.name} (App ID: ${app.id || "unknown"})`);
                    const execString = (app.exec !== undefined && app.exec !== null) ? String(app.exec) : "";
                    const commandArgs = Array.isArray(app.command) ? app.command : (app.command && app.command.length !== undefined) ? Array.from(app.command) : [];
                    let hasQuotedArgs = execString.includes("\"") || execString.includes("'");
                    let hasSpaceArgs = false;
                    if (!hasQuotedArgs)
                        hasQuotedArgs = commandArgs.some((arg) => {
                        const text = String(arg);
                        return text.includes("\"") || text.includes("'");
                    });

                    if (!hasSpaceArgs)
                        hasSpaceArgs = commandArgs.some((arg) => {
                        return String(arg).includes(" ");
                    });

                    if (app.execute && (hasQuotedArgs || hasSpaceArgs)) {
                        Logger.d("ApplicationsProvider", `Detected quoted/space arguments in Exec for ${app.name}, using app.execute()`);
                        app.execute();
                        return ;
                    }
                    if (app.runInTerminal && Config.data.appLauncher.terminalCommand.trim() !== "") {
                        Logger.d("ApplicationsProvider", "Executing terminal app manually: " + app.name);
                        const terminal = Config.data.appLauncher.terminalCommand.trim().split(" ");
                        const command = terminal.concat(app.command);
                        Logger.d("ApplicationsProvider", "Executing command (manual terminal): " + command.join(" "));
                        CompositorService.spawn(command);
                    } else if (app.command && app.command.length > 0) {
                        Logger.d("ApplicationsProvider", "Executing command: " + app.command.join(" "));
                        CompositorService.spawn(app.command);
                    } else if (app.execute) {
                        Logger.d("ApplicationsProvider", "Calling app.execute() for: " + app.name);
                        app.execute();
                    } else {
                        Logger.w("ApplicationsProvider", `Could not launch: ${app.name}. No valid launch method.`);
                    }
                });
            }
        };
    }

    // -------------------------
    // Usage tracking helpers
    function getAppKey(app) {
        if (app && app.id)
            return String(app.id);

        if (app && app.command && app.command.join)
            return app.command.join(" ");

        return String(app && app.name ? app.name : "unknown");
    }

    function getUsageCount(app) {
        return ShellState.getLauncherUsageCount(getAppKey(app));
    }

    // Migrate legacy command-based usage keys to canonical app-id keys at startup
    function migrateLegacyUsageKeys() {
        for (let i = 0; i < entries.length; i++) {
            const app = entries[i];
            if (app && app.id && app.command && app.command.join) {
                const key = getAppKey(app);
                const legacyKey = app.command.join(" ");
                if (legacyKey !== key && ShellState.getLauncherUsageCount(legacyKey) > 0) {
                    ShellState.migrateLauncherUsage(legacyKey, key);
                    Logger.d("ApplicationsProvider", `Migrated usage: "${legacyKey}" → "${key}"`);
                }
            }
        }
    }

    // Reload applications when desktop entries change on disk
    Connections {
        function onValuesChanged() {
            Logger.d("ApplicationsProvider", "Desktop entries changed, reloading applications");
            loadApplications();
        }

        target: typeof DesktopEntries !== 'undefined' ? DesktopEntries.applications : null
    }

}

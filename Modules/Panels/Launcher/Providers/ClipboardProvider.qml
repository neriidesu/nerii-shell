import QtQuick
import Quickshell
import qs.Commons
import qs.Services

Item {
    // Do nothing

    id: root

    // Provider metadata
    property string name: "Clipboard"
    property var launcher: null
    property string supportedLayouts: "list" // List view for clipboard content
    property bool wrapNavigation: false // Don't wrap at end of list
    // Provider capabilities
    // Don't handle regular search
    property bool handleSearch: false
    // Preview support
    //Config.data.appLauncher.enableClipPreview
    property bool hasPreview: true
    property string previewComponentPath: "./ClipboardPreview.qml"
    // Image handling - expose revision for reactive updates in delegates
    readonly property int imageRevision: ClipboardService.revision
    // Internal state
    property bool isWaitingForData: false
    property bool gotResults: false
    property string lastSearchText: ""
    // clear command definition
    readonly property var cmdClear: {
        "name": ">clip clear",
        "description": "Clear clipboard history",
        "icon": "",
        "isTablerIcon": true,
        "isImage": false,
        "onActivate": function() {
            ClipboardService.wipeAll();
            launcher.close();
        }
    }
    readonly property var clipboardLoadingPrompt: {
        "name": "Clipboard loading...",
        "description": "Loading clipboard history from cliphist...",
        "icon": "󰑐",
        "isTablerIcon": true,
        "isImage": false,
        "onActivate": function() {
        }
    }

    // Initialize provider
    function init() {
        Logger.d("ClipboardProvider", "Initialized");
        // Pre-load clipboard data if service is active
        if (ClipboardService.active)
            ClipboardService.list(100);

    }

    // Called when launcher opens
    function onOpened() {
        isWaitingForData = true;
        gotResults = false;
        lastSearchText = "";
        // Refresh clipboard history when launcher opens
        if (ClipboardService.active)
            ClipboardService.list(100);

    }

    // Check if this provider handles the command
    function handleCommand(searchText) {
        return searchText.startsWith(">clip");
    }

    // Return available commands when user types ">"
    function commands() {
        return [{
            "name": ">clip",
            "description": "Search clipboard history",
            "icon": "",
            "isTablerIcon": true,
            "isImage": false,
            "onActivate": function() {
                launcher.setSearchText(">clip ");
            }
        }, cmdClear];
    }

    function getResults(searchText) {
        if (!searchText.startsWith(">clip"))
            return [];

        const results = [];
        // trim command input
        const query = searchText.slice(5).trim();
        // Check if clipboard service is active
        if (!ClipboardService.active)
            return [{
            "name": "Clipboard history disabled",
            "description": "Clipboard history has been disabled",
            "icon": "󰑐",
            "isTablerIcon": true,
            "isImage": false,
            "onActivate": function() {
            }
        }];

        // Special command: clear
        if (query === "clear")
            return [cmdClear];

        // Show loading state if data is being loaded
        if (ClipboardService.loading || isWaitingForData)
            return [clipboardLoadingPrompt];

        // Get clipboard items
        const items = ClipboardService.items || [];
        // If no items and we haven't tried loading yet, trigger a load
        if (items.count === 0 && !ClipboardService.loading) {
            isWaitingForData = true;
            ClipboardService.list(100);
            return [clipboardLoadingPrompt];
        }
        // Search clipboard items
        const searchTerm = query.toLowerCase();
        const now = Date.now() / 1000;
        // Filter and format results
        items.forEach(function(item) {
            const preview = (item.preview || "").toLowerCase();
            // Skip if search term doesn't match
            if (searchTerm && preview.indexOf(searchTerm) === -1)
                return ;

            const firstSeen = ClipboardService.firstSeenById[item.id] || now;
            // Format the result based on type
            let entry;
            if (item.isImage)
                entry = formatImageEntry(item, firstSeen);
            else
                entry = formatTextEntry(item, firstSeen);
            // Add activation handler
            entry.onActivate = function() {
                ClipboardService.copyToClipboard(item.id);
                launcher.close();
            };
            results.push(entry);
        });
        // Show empty state if no results
        if (results.length === 0)
            results.push({
            "name": searchTerm ? "No matching clipboard items" : "Clipboard is empty",
            "description": searchTerm ? `No items containing "${query}"` : "Copy something to see it here",
            "icon": "",
            "isTablerIcon": true,
            "isImage": false,
            "onActivate": function() {
            }
        });

        return results;
    }

    function formatImageEntry(item, firstSeen) {
        const meta = ClipboardService.parseImageMeta(item.preview);
        const timeStr = Time.formatRelativeTime(new Date(firstSeen * 1000));
        let desc = meta ? `${meta.fmt} • ${meta.size}` : item.mime || "Image data";
        if (timeStr)
            desc += ` • ${timeStr}`;

        return {
            "name": meta ? `Image ${meta.w}×${meta.h}` : "Image",
            "description": desc,
            "icon": "",
            "isTablerIcon": true,
            "isImage": true,
            "imageWidth": meta ? meta.w : 0,
            "imageHeight": meta ? meta.h : 0,
            "clipboardId": item.id,
            "mime": item.mime,
            "preview": item.preview,
            "provider": root
        };
    }

    function formatTextEntry(item, firstSeen) {
        const preview = (item.preview || "").trim();
        const lines = preview.split('\n').filter((l) => {
            return l.trim();
        });
        let title = lines[0] || "Empty text";
        if (title.length > 60)
            title = title.substring(0, 57) + "...";

        let description = "";
        if (lines.length > 1) {
            description = lines[1];
            if (description.length > 80)
                description = description.substring(0, 77) + "...";

        } else {
            // Preview is truncated at ~100 chars, so we can't show exact count
            if (preview.length >= 100) {
                description = "Preview longer than 100 characters";
            } else {
                const chars = preview.length;
                const words = preview.split(/\s+/).length;
                description = `${chars} characters, ${words} word${words !== 1 ? 's' : ''}`;
            }
        }
        const timeStr = Time.formatRelativeTime(new Date(firstSeen * 1000));
        if (timeStr)
            description += ` • ${timeStr}`;

        let defaultIcon = "";
        let colorHex = "";
        if (item.contentType === "link") {
            defaultIcon = "󰌷";
        } else if (item.contentType === "file") {
            defaultIcon = "";
        } else if (item.contentType === "code") {
            defaultIcon = "";
        } else if (item.contentType === "color") {
            defaultIcon = "";
            colorHex = preview;
        }
        return {
            "name": title,
            "description": description,
            "icon": defaultIcon,
            "isTablerIcon": true,
            "isImage": false,
            "clipboardId": item.id,
            "preview": preview,
            "contentType": item.contentType,
            "colorHex": colorHex,
            "provider": root
        };
    }

    // Listen for clipboard data updates
    Connections {
        // Do not update results after the first fetch.
        // This will avoid the list resetting every 2seconds when the service updates.

        function onListCompleted() {
            if (gotResults && (lastSearchText === searchText))
                return ;

            // Refresh results if we're waiting for data or if clipboard plugin is active
            if (isWaitingForData || (launcher && launcher.searchText.startsWith(">clip"))) {
                isWaitingForData = false;
                gotResults = true;
                if (launcher)
                    launcher.updateResults();

            }
        }

        function onActiveChanged() {
            // When active state changes (e.g. dependency check completes), refresh results
            if (ClipboardService.active && launcher && launcher.searchText.startsWith(">clip")) {
                isWaitingForData = true;
                gotResults = false;
                ClipboardService.list(100);
            }
        }

        target: ClipboardService
    }

}

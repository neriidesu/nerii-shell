import "../../../Helpers/GridNavigation.js" as LauncherNav
import "Providers"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.Commons
import qs.Services
import qs.Services
import qs.Widgets

// Core launcher logic and UI
Rectangle {
    id: root

    // External interface - set by parent
    property var screen: null
    property bool isOpen: false
    // State
    property string searchText: ""
    property int selectedIndex: 0
    property var results: []
    property var providers: []
    property var activeProvider: null
    property bool resultsReady: false
    property var pluginProviderInstances: ({
    })
    property bool ignoreMouseHover: true // Transient flag, should always be true on init
    // Global mouse tracking for movement detection across delegates
    property real globalLastMouseX: 0
    property real globalLastMouseY: 0
    property bool globalMouseInitialized: false
    property bool mouseTrackingReady: false // Delay tracking until panel is settled
    // ---
    readonly property var defaultProvider: appsProvider
    readonly property var currentProvider: activeProvider || defaultProvider
    // ---
    readonly property int effectiveIconSize: 36
    readonly property int badgeSize: effectiveIconSize
    readonly property int entryHeight: badgeSize + Style.marginXL + Style.marginS
    // Check if current provider allows wrap navigation (default true)
    readonly property bool allowWrapNavigation: {
        var provider = activeProvider || currentProvider;
        return provider && provider.wrapNavigation !== undefined ? provider.wrapNavigation : true;
    }

    signal requestClose()
    signal requestCloseImmediately()

    function closeImmediately() {
        requestCloseImmediately();
    }

    function onOpened() {
        ignoreMouseHover = true;
        globalMouseInitialized = false;
        mouseTrackingReady = false;
        mouseTrackingDelayTimer.restart();
        // Show launcher immediately, results will populate asynchronously
        resultsReady = true;
        focusSearchInput();
        Qt.callLater(() => {
            for (let provider of providers) {
                if (provider.onOpened)
                    provider.onOpened();

            }
            updateResults();
        });
    }

    function onClosed() {
        searchText = "";
        ignoreMouseHover = true;
        if (resultsSwapView)
            resultsSwapView.resetVisuals();

        for (let provider of providers) {
            if (provider.onClosed)
                provider.onClosed();

        }
    }

    function close() {
        requestClose();
    }

    // Public API
    function setSearchText(text) {
        searchText = text;
    }

    function focusSearchInput() {
        if (searchInput.inputItem)
            searchInput.inputItem.forceActiveFocus();

    }

    // Provider registration
    function registerProvider(provider) {
        providers.push(provider);
        provider.launcher = root;
        if (provider.init)
            provider.init();

    }

    // Search handling
    function updateResults() {
        results = [];
        var newActiveProvider = null;
        // Check for command mode
        if (searchText.startsWith(">")) {
            for (let provider of providers) {
                if (provider.handleCommand && provider.handleCommand(searchText)) {
                    newActiveProvider = provider;
                    results = provider.getResults(searchText);
                    break;
                }
            }
            // Show available commands if just ">" or filter commands if partial match
            if (!newActiveProvider) {
                let allCommands = [];
                for (let provider of providers) {
                    if (provider.commands)
                        allCommands = allCommands.concat(provider.commands());

                }
                if (searchText === ">") {
                    results = allCommands;
                } else if (searchText.length > 1) {
                    const query = searchText.substring(1);
                    if (typeof FuzzySort !== 'undefined') {
                        const fuzzyResults = FuzzySort.go(query, allCommands, {
                            "keys": ["name"],
                            "limit": 50
                        });
                        results = fuzzyResults.map((result) => {
                            return result.obj;
                        });
                    } else {
                        const queryLower = query.toLowerCase();
                        results = allCommands.filter((cmd) => {
                            return (cmd.name || "").toLowerCase().includes(queryLower);
                        });
                    }
                }
            }
        } else {
            // Regular search - let providers contribute results
            let allResults = [];
            for (let provider of providers) {
                if (provider.handleSearch) {
                    const providerResults = provider.getResults(searchText);
                    allResults = allResults.concat(providerResults);
                }
            }
            // Sort by _score (higher = better match), items without _score go first
            if (searchText.trim() !== "") {
                const boostByUsage = true;
                allResults.sort((a, b) => {
                    let sa = a._score !== undefined ? a._score : 0;
                    let sb = b._score !== undefined ? b._score : 0;
                    // Boost scores for frequently used items from tracked providers
                    // _score is normalized 0–1, so boost is scaled to nudge, not overwhelm
                    if (boostByUsage) {
                        if (a.provider && a.provider.trackUsage && a.usageKey)
                            sa += 0.1 * Math.log2(1 + ShellState.getLauncherUsageCount(a.usageKey));

                        if (b.provider && b.provider.trackUsage && b.usageKey)
                            sb += 0.1 * Math.log2(1 + ShellState.getLauncherUsageCount(b.usageKey));

                    }
                    return sb - sa;
                });
            }
            results = allResults;
        }
        // Update activeProvider only after computing new state to avoid UI flicker
        activeProvider = newActiveProvider;
        selectedIndex = 0;
    }

    // Navigation functions (delegated to LauncherNavigation.js)
    function selectNext() {
        selectedIndex = LauncherNav.selectNext(selectedIndex, results.length);
    }

    function selectPrevious() {
        selectedIndex = LauncherNav.selectPrevious(selectedIndex, results.length);
    }

    function selectNextWrapped() {
        selectedIndex = LauncherNav.selectNextWrapped(selectedIndex, results.length, allowWrapNavigation);
    }

    function selectPreviousWrapped() {
        selectedIndex = LauncherNav.selectPreviousWrapped(selectedIndex, results.length, allowWrapNavigation);
    }

    function selectFirst() {
        selectedIndex = LauncherNav.selectFirst();
    }

    function selectLast() {
        selectedIndex = LauncherNav.selectLast(results.length);
    }

    function selectNextPage() {
        selectedIndex = LauncherNav.selectNextPage(selectedIndex, results.length, entryHeight);
    }

    function selectPreviousPage() {
        selectedIndex = LauncherNav.selectPreviousPage(selectedIndex, results.length, entryHeight);
    }

    // ---
    function activate() {
        if (results.length > 0 && results[selectedIndex]) {
            const item = results[selectedIndex];
            const provider = item.provider || currentProvider;
            // Track usage for providers that opt in (cross-provider "most used" tracking)
            if (provider && provider.trackUsage && item.usageKey)
                ShellState.recordLauncherUsage(item.usageKey);

            // Check if auto-paste is enabled and provider/item supports it
            if (provider && provider.supportsAutoPaste && item.autoPasteText) {
                if (item.onAutoPaste)
                    item.onAutoPaste();

                closeImmediately();
                Qt.callLater(() => {
                    ClipboardService.pasteText(item.autoPasteText);
                });
                return ;
            }
            if (item.onActivate)
                item.onActivate();

        }
    }

    // Keyboard handler
    function handleKeyPress(event) {
        switch (event.key) {
        case Qt.Key_Escape:
            close();
            event.accepted = true;
            break;
        case Qt.Key_Enter:
            activate();
            event.accepted = true;
            break;
        case Qt.Key_Return:
            activate();
            event.accepted = true;
            break;
        case Qt.Key_Up:
            selectPreviousWrapped();
            event.accepted = true;
            break;
        case Qt.Key_Down:
            selectNextWrapped();
            event.accepted = true;
            break;
        case Qt.Key_Home:
            selectFirst();
            event.accepted = true;
            break;
        case Qt.Key_End:
            selectLast();
            event.accepted = true;
            break;
        case Qt.Key_PageUp:
            selectPreviousPage();
            event.accepted = true;
            break;
        case Qt.Key_PageDown:
            selectNextPage();
            event.accepted = true;
            break;
        case Qt.Key_Delete:
            if (selectedIndex >= 0 && results && results[selectedIndex]) {
                var item = results[selectedIndex];
                var provider = item.provider || currentProvider;
                if (provider && provider.canDeleteItem && provider.canDeleteItem(item))
                    provider.deleteItem(item);

            }
            event.accepted = true;
            break;
        }
    }

    color: "transparent"
    // Lifecycle
    onIsOpenChanged: {
        if (isOpen)
            onOpened();
        else
            onClosed();
    }
    onSearchTextChanged: {
        if (isOpen)
            updateResults();

    }
    opacity: resultsReady ? 1 : 0

    // -----------------------
    // Provider components
    // -----------------------
    ApplicationsProvider {
        id: appsProvider

        Component.onCompleted: {
            registerProvider(this);
            Logger.d("Launcher", "Registered: ApplicationsProvider");
        }
    }

    ClipboardProvider {
        id: clipProvider

        Component.onCompleted: {
            registerProvider(this);
            Logger.d("Launcher", "Registered: ClipboardProvider");
        }
    }

    CommandProvider {
        id: commandProvider

        Component.onCompleted: {
            registerProvider(this);
            Logger.d("Launcher", "Registered: CommandProvider");
        }
    }

    CalculatorProvider {
        id: calculatorProvider

        Component.onCompleted: {
            registerProvider(this);
            Logger.d("Launcher", "Registered: CalculatorProvider");
        }
    }

    TimeCalculationProvider {
        id: timeCalculationProvider

        Component.onCompleted: {
            registerProvider(this);
            Logger.d("Launcher", "Registered: TimeCalculationProvider");
        }
    }

    FunProvider {
        id: funProvider

        Component.onCompleted: {
            registerProvider(this);
            Logger.d("Launcher", "Registered: FunProvider");
        }
    }

    ReminderProvider {
        id: reminderProvider

        Component.onCompleted: {
            registerProvider(this);
            Logger.d("Launcher", "Registered: ReminderProvider");
        }
    }

    Timer {
        id: mouseTrackingDelayTimer

        interval: (Style.animationNormal + 50) // Wait for panel animation to complete + safety margin
        repeat: false
        onTriggered: {
            root.mouseTrackingReady = true;
            root.globalMouseInitialized = false; // Reset so we get fresh initial position
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.bottomMargin: Style.marginL
        spacing: 0

        NTextInput {
            id: searchInput

            Layout.fillWidth: true
            radius: Style.radiusM
            text: root.searchText
            placeholderText: "Search..."
            fontSize: Style.fontSizeM
            border.width: 0
            onTextChanged: root.searchText = text
            Component.onCompleted: {
                if (searchInput.inputItem) {
                    searchInput.inputItem.forceActiveFocus();
                    searchInput.inputItem.Keys.onPressed.connect(function(event) {
                        root.handleKeyPress(event);
                    });
                }
            }
        }

        NDivider {
            Layout.fillWidth: true
        }

        // Results view
        NSlideSwapView {
            id: resultsSwapView

            Layout.leftMargin: 1
            Layout.rightMargin: 1
            Layout.fillWidth: true
            Layout.fillHeight: true
            animationsEnabled: true
            sourceComponent: listViewComponent
        }

        // --------------------------
        // LIST VIEW
        Component {
            id: listViewComponent

            NListView {
                id: resultsList

                horizontalPolicy: ScrollBar.AlwaysOff
                verticalPolicy: ScrollBar.AlwaysOff
                reserveScrollbarSpace: false
                gradientColor: "transparent"
                wheelScrollMultiplier: 4
                width: parent.width
                height: parent.height
                model: root.results
                currentIndex: root.selectedIndex
                cacheBuffer: resultsList.height * 2
                interactive: false
                onCurrentIndexChanged: {
                    cancelFlick();
                    if (currentIndex >= 0)
                        positionViewAtIndex(currentIndex, ListView.Contain);

                }
                onModelChanged: {
                }

                delegate: LauncherListDelegate {
                    launcher: root
                }

            }

        }

        ColumnLayout {
            Layout.leftMargin: Style.marginL
            Layout.rightMargin: Style.marginL

            NDivider {
                Layout.fillWidth: true
                Layout.bottomMargin: Style.marginS
            }

            NText {
                Layout.fillWidth: true
                text: {
                    if (root.results.length === 0) {
                        if (root.searchText)
                            return "No results...";

                        // Use provider's empty browsing message if available
                        var provider = root.currentProvider;
                        if (provider && provider.emptyBrowsingMessage)
                            return provider.emptyBrowsingMessage;

                        return "";
                    }
                    var prefix = root.activeProvider && root.activeProvider.name ? root.activeProvider.name + ": " : "";
                    return prefix + root.results.length;
                }
                size: Style.fontSizeXS
                color: Colors.md3.surface_variant
                horizontalAlignment: Text.AlignCenter
            }

        }

    }

    Behavior on opacity {
        NumberAnimation {
            duration: Style.animationFast
            easing.type: Easing.OutCirc
        }

    }

}

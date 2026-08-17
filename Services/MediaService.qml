import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.Commons
pragma Singleton

Singleton {
    id: root

    property var currentPlayer: null
    property real currentPosition: 0
    property int selectedPlayerIndex: 0
    property bool isPlaying: currentPlayer ? (currentPlayer.playbackState === MprisPlaybackState.Playing || currentPlayer.isPlaying) : false
    property string trackTitle: currentPlayer ? (currentPlayer.trackTitle !== undefined ? currentPlayer.trackTitle.replace(/(\r\n|\n|\r)/g, "") : "") : ""
    property string trackArtist: currentPlayer ? (currentPlayer.trackArtist || "") : ""
    property string trackAlbum: currentPlayer ? (currentPlayer.trackAlbum || "") : ""
    property string trackArtUrl: currentPlayer ? (currentPlayer.trackArtUrl || "") : ""
    property real trackLength: currentPlayer ? ((currentPlayer.length < infiniteTrackLength) ? currentPlayer.length : 0) : 0
    property bool canPlay: currentPlayer ? currentPlayer.canPlay : false
    property bool canPause: currentPlayer ? currentPlayer.canPause : false
    property bool canGoNext: currentPlayer ? currentPlayer.canGoNext : false
    property bool canGoPrevious: currentPlayer ? currentPlayer.canGoPrevious : false
    property string positionString: formatTime(currentPosition)
    property string lengthString: formatTime(trackLength)
    property real infiniteTrackLength: 9.22337e+11

    function formatTime(seconds) {
        if (isNaN(seconds) || seconds < 0)
            return "0:00";

        var h = Math.floor(seconds / 3600);
        var m = Math.floor((seconds % 3600) / 60);
        var s = Math.floor(seconds % 60);
        var pad = function pad(n) {
            return (n < 10) ? ("0" + n) : n;
        };
        if (h > 0)
            return h + ":" + pad(m) + ":" + pad(s);
        else
            return m + ":" + pad(s);
    }

    function getAvailablePlayers() {
        if (!Mpris.players || !Mpris.players.values)
            return [];

        let allPlayers = Mpris.players.values;
        // Filter for controllable players
        let controllablePlayers = [];
        for (var i = 0; i < allPlayers.length; i++) {
            let player = allPlayers[i];
            if (player && player.canPlay)
                controllablePlayers.push(player);

        }
        return controllablePlayers;
    }

    function updateCurrentPlayer() {
        let newPlayer = findActivePlayer();
        if (newPlayer !== currentPlayer) {
            currentPlayer = newPlayer;
            currentPosition = currentPlayer ? currentPlayer.position : 0;
            Logger.d("Media", "Switching player");
        }
    }

    function findActivePlayer() {
        let availablePlayers = getAvailablePlayers();
        if (availablePlayers.length === 0)
            return null;

        // Prioritize the actively playing player ---
        for (var i = 0; i < availablePlayers.length; i++) {
            if (availablePlayers[i] && availablePlayers[i].playbackState === MprisPlaybackState.Playing) {
                Logger.d("Media", "Found actively playing player: " + availablePlayers[i].identity);
                selectedPlayerIndex = i;
                return availablePlayers[i];
            }
        }
        // fallback if nothing is playing)
        const preferred = (Config.data.media.preferredPlayer || "");
        if (preferred !== "") {
            for (var i = 0; i < availablePlayers.length; i++) {
                const p = availablePlayers[i];
                const identity = String(p.identity || "").toLowerCase();
                const pref = preferred.toLowerCase();
                if (identity.includes(pref)) {
                    selectedPlayerIndex = i;
                    return p;
                }
            }
        }
        if (selectedPlayerIndex < availablePlayers.length) {
            return availablePlayers[selectedPlayerIndex];
        } else {
            selectedPlayerIndex = 0;
            return availablePlayers[0];
        }
    }

    function playPause() {
        if (currentPlayer) {
            let stateSource = currentPlayer._stateSource || currentPlayer;
            let controlTarget = currentPlayer._controlTarget || currentPlayer;
            if (stateSource.playbackState === MprisPlaybackState.Playing)
                controlTarget.pause();
            else
                controlTarget.play();
        }
    }

    function play() {
        let target = currentPlayer ? (currentPlayer._controlTarget || currentPlayer) : null;
        if (target && target.canPlay)
            target.play();

    }

    function stop() {
        let target = currentPlayer ? (currentPlayer._controlTarget || currentPlayer) : null;
        if (target)
            target.stop();

    }

    function pause() {
        let target = currentPlayer ? (currentPlayer._controlTarget || currentPlayer) : null;
        if (target && target.canPause)
            target.pause();

    }

    function next() {
        let target = currentPlayer ? (currentPlayer._controlTarget || currentPlayer) : null;
        if (target && target.canGoNext)
            target.next();

    }

    function previous() {
        let target = currentPlayer ? (currentPlayer._controlTarget || currentPlayer) : null;
        if (target && target.canGoPrevious)
            target.previous();

    }

    function increaseVolume() {
        setVolume(getVolume() + 0.05);
    }

    function decreaseVolume() {
        setVolume(getVolume() - 0.05);
    }

    function setVolume(newVolume: real) {
        let target = currentPlayer ? (currentPlayer._controlTarget || currentPlayer) : null;
        if (target && target.volumeSupported)
            target.volume = newVolume;

    }

    function getVolume() {
        let target = currentPlayer ? (currentPlayer._controlTarget || currentPlayer) : null;
        if (target && target.volumeSupported)
            return target.volume;

    }

    Component.onCompleted: {
        updateCurrentPlayer();
    }

    Timer {
        id: playerStateMonitor

        interval: 2000 // Check every 2 seconds
        repeat: true
        running: true
        onTriggered: {
            // Only update if we don't have a playing player or if current player is paused
            if (!currentPlayer || !currentPlayer.isPlaying || currentPlayer.playbackState !== MprisPlaybackState.Playing)
                updateCurrentPlayer();

        }
    }

    Connections {
        function onValuesChanged() {
            Logger.d("Media", "Players changed");
            updateCurrentPlayer();
        }

        target: Mpris.players
    }

}

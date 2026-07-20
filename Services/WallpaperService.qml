import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
pragma Singleton

Singleton {
    property string wallpaperPath: Config.data.wallpaper.wallpaperPath
    property string wallpaperFile
    property bool isAnimated: false
    property bool prevIsAnimated
    property bool hasInitialized: false
    property string lweArgs

    signal wallpaperReloaded()

    function init() {
        if (wallpaperPath == "" || wallpaperPath == undefined)
            Logger.w("WallpaperService", "No wallpaper set");
        else
            loadProperties();
        Logger.d("WallpaperService", "initialized");
        hasInitialized = true;
        if (wallpaperFile != undefined)
            startWallpaper();

    }

    function startWallpaper() {
        if (!hasInitialized) {
            Qt.callLater(startWallpaper);
            return ;
        }
        if (isAnimated) {
            Logger.d("WallpaperService", "Wallpaper is l-we");
            lweArgs = "";
            for (var i = 0; i < Quickshell.screens.length; i++) {
                lweArgs = lweArgs + `--screen-root ${Quickshell.screens[i].name} --bg ${wallpaperFile.slice(0,wallpaperFile.lastIndexOf('.'))} `;
            }
            if (hyprpaper.running)
                hyprpaper.running = false;

            lwe.running = false;
            lwe.command = ["sh", "-c", "linux-wallpaperengine --silent " + lweArgs.trim()];
            lwe.running = true;
        } else {
            Logger.d("WallpaperService", "Wallpaper is hyprpaper");
            if (lwe.running)
                lwe.running = false;

            hyprpaper.running = true;
            delay(150, function() {
                Quickshell.execDetached(["hyprctl", "hyprpaper", "wallpaper", `,${wallpaperPath}`]);
            });
        }
    }

    function setWallpaper(path) {
        Config.data.wallpaper.wallpaperPath = path;
        reload();
    }

    function loadProperties() {
        var pathArr = wallpaperPath.split("/");
        wallpaperFile = pathArr.pop();
        isAnimated = (pathArr.pop() == "we") ? true : false;
        Logger.d("WallpaperService", wallpaperFile, isAnimated);
    }

    function reload() {
        prevIsAnimated = isAnimated;
        loadProperties();
        startWallpaper();
        wallpaperReloaded;
    }

    function delay(delayTime, cb) {
        timer.interval = delayTime;
        timer.repeat = false;
        timer.triggered.connect(cb);
        timer.start();
    }

    function kill() {
        hyprpaper.running = false;
        lwe.running = false;
    }

    Timer {
        id: timer
    }

    Timer {
        id: lweRestartTimer

        interval: 60 * 60 * 1000
        running: lwe.running
        onTriggered: {
            Logger.i("WallpaperService", "Restarting lwe to combat memory leak");
            lwe.running = false;
            lwe.running = true;
        }
    }

    Process {
        id: hyprpaper

        command: ["hyprpaper"]
        running: false
    }

    Process {
        id: lwe

        running: false
    }

}

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
pragma Singleton

Singleton {
    property string wallpaperPath: Config.data.wallpaper.wallpaperPath
    property string lweDir: Config.data.wallpaper.lweDir
    property bool lweEnbaled: Config.data.wallpaper.enableLwe
    property string wallpaperFile
    property bool isAnimated: false
    property bool prevIsAnimated
    property bool hasInitialized: false

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

    function restart() {
        kill();
        delay(30, function() {
            startWallpaper();
        });
    }

    function startWallpaper() {
        if (!hasInitialized) {
            Logger.e("WallpaperService", "Tried to call startWallpaper while WallpaperService not initialized");
            return ;
        }
        if (isAnimated && Config.data.wallpaper.enableLwe) {
            Logger.d("WallpaperService", "Wallpaper is WE");
            let weSteamDir = Quickshell.env("HOME") + "/.local/share/Steam/steamapps/workshop/content/431960/";
            let path = weSteamDir.concat(wallpaperFile.slice(0, wallpaperFile.lastIndexOf('.')));
            Quickshell.execDetached(["sh", "-c", `skwd-paper-v2 apply '*' ${path} --replace-all`]);
        } else {
            Logger.d("WallpaperService", "Wallpaper is static");
            Quickshell.execDetached(["sh", "-c", `skwd-paper-v2 apply '*' ${wallpaperPath} --replace-all`]);
        }
    }

    function setWallpaper(path) {
        Config.data.wallpaper.wallpaperPath = path;
        Quickshell.execDetached(["magick", path, "/usr/share/sddm/themes/nerii-shell/Assets/wallpaper.png"]);
        reload();
    }

    function loadProperties() {
        var pathArr = wallpaperPath.split("/");
        wallpaperFile = pathArr.pop();
        if (lweEnbaled) {
            var lwePathArr = Config.ensureTrailingSlash(lweDir).slice(0, -1).split("/");
            isAnimated = (pathArr.pop() == lwePathArr.pop()) ? true : false;
        }
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
        Quickshell.execDetached(["pkill", "skwd-paper"]);
    }

    function writeLweFiles() {
        Quickshell.execDetached([Quickshell.shellDir + "/Helpers/write_lwe_files", Config.data.wallpaper.lweDir]);
    }

    Timer {
        id: timer
    }

}

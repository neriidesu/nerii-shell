import QtQuick
import Quickshell
import qs.Commons
pragma Singleton

Singleton {
    function init() {
        Logger.d("MatugenService", "initialized");
        gen();
    }

    function fromWallpaper(path) {
        if (!Config.data.colors.genFromWallpaper)
            return ;

        Logger.i("MatugenService", "Generating colors from wallpaper");
        Quickshell.execDetached(["matugen", "image", path, "--source-color-index", 0]);
    }

    function fromColor(hex) {
        Logger.i("MatugenService", `Generating colors from color (${hex})`);
        Quickshell.execDetached(["matugen", "color", "hex", hex]);
    }

    function fromTheme(primaryHex, path) {
        Logger.d("", primaryHex, path);
        Logger.i("MatugenService", `Generating colors from theme (${Config.data.colors.themeName})`);
        Quickshell.execDetached(["matugen", "color", "hex", primaryHex, "--import-json", path]);
    }

    function gen() {
        if (Config.data.colors.genFromWallpaper)
            return ;

        if (Config.data.colors.genFromColor) {
            fromColor(Config.data.colors.primaryHex);
            return ;
        }
        if (Config.data.colors.genWithTheme) {
            fromTheme(Config.data.colors.primaryHex, Config.data.colors.themeDir + Config.data.colors.themeName + ".json");
            return ;
        }
    }

    Connections {
        function onConfigReloaded() {
            gen();
        }

        target: Config
    }

}

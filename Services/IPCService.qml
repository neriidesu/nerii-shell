import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services
pragma Singleton

Singleton {
    // Screen detector, set via init()
    // property var screenDetector: null

    id: root

    function init() {
        // root.screenDetector = detector;
        Logger.i("IPCService", "Service started");
    }

    IpcHandler {
        function increase() {
            AudioService.increaseVolume();
        }

        function decrease() {
            AudioService.decreaseVolume();
        }

        target: "volume"
    }

    IpcHandler {
        function playPause() {
            MediaService.playPause();
        }

        function play() {
            MediaService.play();
        }

        function stop() {
            MediaService.stop();
        }

        function pause() {
            MediaService.stop();
        }

        function next() {
            MediaService.next();
        }

        function previous() {
            MediaService.previous();
        }

        target: "media"
    }

    IpcHandler {
        function setWallpaper(path: string) {
            WallpaperService.setWallpaper(path);
        }

        function kill() {
            WallpaperService.kill();
        }

        function restart() {
            WallpaperService.kill();
            WallpaperService.startWallpaper();
        }

        target: "wallpaper"
    }

    IpcHandler {
        function generateDefaultConfig() {
            Config.generateDefaultConfig();
        }

        function overwriteConfig() {
            Config.configFileView.writeAdapter();
        }

        target: "debug"
    }

    IpcHandler {
        function toggle() {
            var screen = CompositorService.getFocusedScreen();
            PanelService.toggleLauncher(screen);
        }

        function clipboard() {
            var screen = CompositorService.getFocusedScreen();
            var searchText = PanelService.getLauncherSearchText(screen);
            var isInClipMode = searchText.startsWith(">clip");
            if (!PanelService.isLauncherOpen(screen))
                // Closed -> open in clipboard mode
                PanelService.openLauncherWithSearch(screen, ">clip ");
            else if (isInClipMode)
                // Already in clipboard mode -> close
                PanelService.closeLauncher(screen);
            else
                // In another mode -> switch to clipboard mode
                PanelService.setLauncherSearchText(screen, ">clip ");
        }

        target: "launcher"
    }

}

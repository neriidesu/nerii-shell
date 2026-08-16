import Quickshell
import qs.Commons
import qs.Services
pragma Singleton

Singleton {
    function quit() {
        WallpaperService.kill();
        Quickshell.execDetached(["pkill", "qs"]);
    }

}

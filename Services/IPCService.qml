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

}

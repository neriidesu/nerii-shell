import Quickshell
import qs.Commons
pragma Singleton

Singleton {
    id: root

    function _formatMessage(...args) {
        var t = Time.getFormattedTimestamp();
        if (args.length > 1) {
            const maxLength = 14;
            var module = args.shift().substring(0, maxLength).padStart(maxLength, " ");
            return `\x1b[36m[${t}]\x1b[0m \x1b[35m${module}\x1b[0m ` + args.join(" ");
        } else {
            return `[\x1b[36m[${t}]\x1b[0m ` + args.join(" ");
        }
    }

    // Debug log (only when Config.data.misc.debug is true)
    function d(...args) {
        if (Config.data.misc.debug) {
            var msg = _formatMessage(...args);
            console.debug(msg);
        }
    }

    // Info log (always visible)
    function i(...args) {
        var msg = _formatMessage(...args);
        console.info(msg);
    }

    // Warning log (always visible)
    function w(...args) {
        var msg = _formatMessage(...args);
        console.warn(msg);
    }

    // Error log (always visible)
    function e(...args) {
        var msg = _formatMessage(...args);
        console.error(msg);
    }

}

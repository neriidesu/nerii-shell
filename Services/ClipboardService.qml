import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
pragma Singleton

Singleton {
    id: root

    property bool loading: false
    property var items: []
    // Approximate first-seen timestamps for entries this session (seconds)
    property var firstSeenById: ({
    })
    // Track the most recent clipboard content for instant access
    property string _latestTextContent: ""
    property string _latestTextId: ""
    // Local content cache - stores full text content by ID
    // This avoids relying on cliphist decode which can be unreliable
    property var contentCache: ({
    })
    // Expose decoded thumbnails by id and a revision to notify bindings
    property var imageDataById: ({
    })
    property var _imageDataInsertOrder: [] // insertion-order IDs for LRU eviction
    readonly property int _imageDataMaxEntries: 20 // max decoded images held in RAM at once
    property int revision: 0

    // Internal: store callback for decode
    property var _decodeCallback: null
    property int _decodeRequestId: 0

    signal listCompleted()

    function get() {
        decode(1309, (cb) => {
            Logger.d("h", cb);
        });
    }

    // Async decode - checks cache first, then falls back to cliphist
    function decode(id, cb) {
        // Check cache first
        const cached = root.contentCache[id];
        if (cached) {
            if (cb)
                cb(cached);

            return ;
        }
        // Fall back to cliphist decode
        if (decodeProc.running)
            decodeProc.running = false;
        root._decodeRequestId++;
        decodeProc.requestId = root._decodeRequestId;
        root._decodeCallback = function(content) {
            // Cache the result if successful
            if (content && content.trim())
                root.contentCache[id] = content;

            if (cb)
                cb(content);

        };
        const idStr = String(id);
        decodeProc.command = ["cliphist", "decode", idStr];
        decodeProc.running = true;
    }

    // Get content for an ID - uses cache first, falls back to cliphist decode
    function getContent(id) {
        if (root.contentCache[id])
            return root.contentCache[id];

        return null;
    }

    // Capture current clipboard text and cache it
    function captureCurrentClipboard() {
        if (captureTextProc.running)
            return ;

        captureTextProc.command = ["wl-paste", "--no-newline"];
        captureTextProc.running = true;
    }

    function list(maxPreviewWidth) {
        if (listProc.running)
            return ;

        loading = true;
        const width = maxPreviewWidth || 100;
        listProc.command = ["cliphist", "list", "-preview-width", String(width)];
        listProc.running = true;
    }

    // Fallback: periodically refresh list so UI updates even if not in clip mode
    Timer {
        interval: 5000
        repeat: true
        running: true
        onTriggered: list()
    }

    Process {
        id: decodeProc
        property int requestId: 0
        stdout: StdioCollector {}
        onExited: (exitCode, exitStatus) => {
            if (requestId === root._decodeRequestId && root._decodeCallback) {
                const out = String(stdout.text);
                try {
                    root._decodeCallback(out);
                } finally {
                    root._decodeCallback = null;
                }
            }
        }
    }

    Process {
        id: listProc

        onExited: (exitCode, exitStatus) => {
            const out = String(stdout.text);
            const lines = out.split('\n').filter((l) => {
                return l.length > 0;
            });
            // cliphist list default format: "<id> <preview>" or "<id>\t<preview>"
            // map lines to parsed format
            const parsed = lines.map((l, i) => {
                let id = "";
                let preview = "";
                // get id and preview of item
                // check if line matches "<id> <preview>"
                const match = l.match(/^(\d+)\s+(.+)$/);
                if (match) {
                    id = match[1];
                    preview = match[2];
                } else {
                    // assume using "<id>\t<preview>"
                    const tab = l.indexOf('\t');
                    id = tab > -1 ? l.slice(0, tab) : l;
                    preview = tab > -1 ? l.slice(tab + 1) : "";
                }
                // prepare for image parsing
                const lower = preview.toLowerCase();
                const isImage = lower.startsWith("[image]") || lower.includes(" binary data ");
                // Best-effort mime guess from preview
                var mime = "text/plain";
                if (isImage) {
                    if (lower.includes(" png"))
                        mime = "image/png";
                    else if (lower.includes(" jpg") || lower.includes(" jpeg"))
                        mime = "image/jpeg";
                    else if (lower.includes(" webp"))
                        mime = "image/webp";
                    else if (lower.includes(" gif"))
                        mime = "image/gif";
                    else
                        mime = "image/*";
                }
                // Record first seen time for new ids (approximate copy time)
                if (!root.firstSeenById[id]) {
                    const assumedAge = i * 15 * 60;
                    root.firstSeenById[id] = Time.timestamp - assumedAge;
                }
                // Smart type detection
                var contentType = "text";
                if (isImage) {
                    contentType = "image";
                } else {
                    const t = preview.trim();
                    const tLower = t.toLowerCase();
                    if (/^#([a-f0-9]{3}|[a-f0-9]{6}|[a-f0-9]{8})$/.test(tLower))
                        contentType = "color";
                    else if (/^https?:\/\//i.test(t))
                        contentType = "link";
                    else if (/^(\/|~\/|file:\/\/)/i.test(t) && !t.startsWith('//') && !t.includes('\n'))
                        contentType = "file";
                    else if ((t.includes('{') && t.includes('}') && (t.includes(';') || t.includes('='))) || t.includes('</') || t.includes('/>') || t.includes('=>') || t.includes('===') || t.includes('!==') || t.includes('::') || t.includes('->') || /^(?:const|let|var|function|class|struct|interface|type|enum|import|export|func|fn|pub|def|using|namespace|property|public|private|protected)\b/i.test(t) || /^(?:#include|#define|#\[|@|\/\/|\/\*|<\?|<html|<body|<!DOCTYPE)/i.test(t) || /\b(?:require\(|module\.exports)\b/i.test(t))
                        contentType = "code";
                }
                return {
                    "id": id,
                    "preview": preview,
                    "isImage": isImage,
                    "mime": mime,
                    "contentType": contentType
                };
            });
            // Filter out browser junk when copying images
            const filtered = parsed.filter((item) => {
                if (item.isImage)
                    return true;

                const p = item.preview;
                // Skip UTF-16 encoded text (has null bytes between chars), chromium browser artifact
                const nullCount = (p.match(/\x00/g) || []).length;
                if (nullCount > p.length * 0.2)
                    return false;

                // Skip browser-generated HTML wrapper, firefox
                if (p.toLowerCase().startsWith("<meta http-equiv="))
                    return false;

                return true;
            });
            items = filtered;
            loading = false;
            // Try to capture current clipboard and associate with newest item
            if (filtered.length > 0 && !filtered[0].isImage && !root.contentCache[filtered[0].id])
                root.captureCurrentClipboard();

            root.listCompleted();
        }

        stdout: StdioCollector {
        }

    }

    Process {
        id: captureTextProc

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                const content = String(stdout.text);
                if (content.length > 0) {
                    root._latestTextContent = content;
                    // Associate with newest item if we have one
                    if (root.items.length > 0 && !root.items[0].isImage) {
                        const newestId = root.items[0].id;
                        if (!root.contentCache[newestId]) {
                            root.contentCache[newestId] = content;
                            root.revision++;
                        }
                    }
                }
            }
        }

        stdout: StdioCollector {
        }

    }

    Process {
        id: copyProc

        stdout: StdioCollector {
        }

    }

    Process {
        id: pasteProc

        stdout: StdioCollector {
        }

    }

    Process {
        id: deleteProc

        onExited: (exitCode, exitStatus) => {
            revision++;
            Qt.callLater(() => {
                return list();
            });
        }

        stdout: StdioCollector {
        }

    }

}

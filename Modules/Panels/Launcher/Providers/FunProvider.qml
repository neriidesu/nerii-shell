import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
    property var launcher: null
    property string name: "Commands"
    readonly property var cmdNeko: {
        "name": ">neko",
        "description": "Generates a random catgirl",
        "icon": "",
        "isTablerIcon": true,
        "isImage": false,
        "onActivate": function() {
            neko();
        }
    }

    function commands() {
        return [cmdNeko];
    }

    function neko() {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var id = JSON.parse(xhr.responseText.toString())["images"][0]["id"];
                launcher.closeImmediately();
                Qt.callLater(() => {
                    Quickshell.execDetached(["firefox", "--new-window", `https://nekos.moe/image/${id}`]);
                });
            }
        };
        xhr.open("GET", "https://nekos.moe/api/v1/random/image?nsfw=false");
        xhr.send();
    }

}

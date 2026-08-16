import "../Launcher/Helpers/LauncherNavigation.js" as LauncherNav
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Modules.Core
import qs.Services
import qs.Widgets

SmartPanel {
    // select wallpaper

    id: root

    property int selectedIndex: 0
    property bool gotStaticWallpapers: false
    property bool gotLweWallpapers: false
    property int gridColumns: 4
    property string wallpaperDir: Config.data.wallpaper.wallpaperDir
    property string wallpaperCacheDir: Config.cacheDir + "wallpaperPreviews/static/"
    property string lweDir: Config.data.wallpaper.lweDir
    property string lweCacheDir: Config.cacheDir + "wallpaperPreviews/lwe/"
    property bool isReady: gotStaticWallpapers && (Config.data.wallpaper.enableLwe ? gotLweWallpapers : true)
    readonly property string wallpaperlBin: Quickshell.shellDir + "/Helpers/wallpaperl"

    function getWallpapers() {
        if (wallpaperDir == "") {
            Logger.w("WallpaperPanel", "No wallpaper dir chosen.");
            return ;
        }
        wallpaperlGenProcStatic.exec([wallpaperlBin, "genpreviews", wallpaperDir, wallpaperCacheDir]);
        if (!Config.data.wallpaper.enableLwe)
            return ;

        if (lweDir == "") {
            Logger.w("WallpaperPanel", "No lwe dir chosen.");
            return ;
        }
        wallpaperlGenProcLwe.exec([wallpaperlBin, "genpreviews", lweDir, lweCacheDir]);
    }

    function onEnterPressed() {
        Logger.i("WallpaperPanel", "Selected wallpaper:", wallpaperModel.get(selectedIndex).path, wallpaperModel.get(selectedIndex).isAnimated);
        wallpaperlGetProc.exec([wallpaperlBin, "get", wallpaperModel.get(selectedIndex).path, wallpaperModel.get(selectedIndex).isAnimated, wallpaperDir, lweDir]);
        close();
    }

    function onUpPressed() {
        selectedIndex = LauncherNav.selectPreviousRow(selectedIndex, wallpaperModel.count, gridColumns);
    }

    function onDownPressed() {
        selectedIndex = LauncherNav.selectNextRow(selectedIndex, wallpaperModel.count, gridColumns);
    }

    function onRightPressed() {
        selectedIndex = LauncherNav.selectNext(selectedIndex, wallpaperModel.count);
    }

    function onLeftPressed() {
        selectedIndex = LauncherNav.selectPrevious(selectedIndex, wallpaperModel.count);
    }

    function onHomePressed() {
        selectedIndex = LauncherNav.selectFirst();
    }

    function onEndPressed() {
        selectedIndex = LauncherNav.selectLast(wallpaperModel.count);
    }

    verticalPosition: "center"
    Component.onCompleted: {
        getWallpapers();
    }

    ListModel {
        id: wallpaperModel
    }

    Process {
        id: wallpaperlGetProc

        stdout: StdioCollector {
            onStreamFinished: {
                WallpaperService.setWallpaper(this.text);
                Quickshell.execDetached(["matugen", "image", this.text, "--source-color-index", 0]);
                ToastService.showIconNotice("Wallpaper", "Wallpaper has been updated", this.text);
            }
        }

    }

    Process {
        id: wallpaperlGenProcStatic

        stdout: StdioCollector {
            onStreamFinished: {
                if (wallpaperCacheDir == "") {
                    Logger.w("WallpaperPanel", "No wallpaper dir chosen.");
                    return ;
                }
                wallpaperlProcStatic.exec([wallpaperlBin, "list", wallpaperCacheDir]);
            }
        }

    }

    Process {
        id: wallpaperlGenProcLwe

        stdout: StdioCollector {
            onStreamFinished: {
                if (lweCacheDir == "") {
                    Logger.w("WallpaperPanel", "No lwe dir chosen.");
                    return ;
                }
                wallpaperlProcLwe.exec([wallpaperlBin, "list", lweCacheDir]);
            }
        }

    }

    Process {
        id: wallpaperlProcStatic

        stdout: StdioCollector {
            onStreamFinished: {
                for (const path of this.text.split(',')) {
                    wallpaperModel.append({
                        "path": path.trim(),
                        "isAnimated": false
                    });
                }
                gotStaticWallpapers = true;
            }
        }

    }

    Process {
        id: wallpaperlProcLwe

        stdout: StdioCollector {
            onStreamFinished: {
                for (const path of this.text.split(',')) {
                    wallpaperModel.append({
                        "path": path.trim(),
                        "isAnimated": true
                    });
                }
                gotLweWallpapers = true;
            }
        }

    }

    Connections {
        function onEnableLweChanged() {
            getWallpapers();
        }

        target: Config.data.wallpaper
    }

    panelContent: Item {
        id: panelContent

        readonly property real contentPreferredWidth: (240 + Style.marginL) * root.gridColumns + Style.marginL * 3
        readonly property real contentPreferredHeight: 800 + Style.marginM

        anchors.fill: parent

        Rectangle {
            id: content

            color: root.panelBackgroundColor
            width: parent.width
            height: parent.height
            radius: Style.radiusM
            topLeftRadius: root.isConnected ? 0 : undefined
            topRightRadius: root.isConnected ? 0 : undefined

            border {
                color: root.panelBorderColor
                width: Style.borderM
            }

            NGridView {
                id: gridView

                anchors.topMargin: Style.borderM
                anchors.bottomMargin: Style.borderM
                visible: isReady
                anchors.fill: parent
                model: wallpaperModel
                cellWidth: 240 + Style.marginL
                cellHeight: 135 + Style.marginL
                leftMargin: Style.marginL
                topMargin: Style.marginL
                rightMargin: Style.marginL
                bottomMargin: Style.marginL
                currentIndex: root.selectedIndex

                delegate: Item {
                    width: 240
                    height: 135

                    Rectangle {
                        color: "transparent"
                        anchors.fill: parent
                        radius: Style.radiusM
                        clip: true

                        Rectangle {
                            anchors.fill: parent
                            color: gridView.currentIndex == index ? root.panelBorderColor : "transparent"
                            radius: Style.radiusM
                        }

                        Rectangle {
                            anchors.fill: preview
                            color: preview.status == Image.Ready ? (isAnimated ? Colors.md3.tertiary : "transparent") : "transparent"
                            radius: Style.radiusM
                        }

                        NImageRounded {
                            id: preview

                            radius: Style.radiusM
                            cache: true
                            anchors.fill: parent
                            anchors.margins: Style.borderL
                            fillMode: Image.PreserveAspectCrop
                            source: path
                            sourceWidth: 240
                            visible: !isAnimated
                        }

                        Image {
                            id: mask

                            // sourceSize.height: 135
                            asynchronous: true
                            cache: true
                            anchors.fill: parent
                            anchors.margins: Style.borderL
                            fillMode: Image.PreserveAspectCrop
                            source: Quickshell.shellDir + "/Assets/mask.png"
                            sourceSize.width: 240
                            visible: false
                        }

                        OpacityMask {
                            anchors.fill: preview
                            source: preview
                            maskSource: mask
                            visible: isAnimated
                        }

                    }

                    MouseArea {
                        acceptedButtons: Qt.LeftButton
                        anchors.fill: parent
                        onClicked: {
                            root.selectedIndex = index;
                        }
                        onDoubleClicked: {
                            root.selectedIndex = index;
                            onEnterPressed();
                        }
                    }

                }

            }

        }

    }

}

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
    id: root
    property var pluginApi: null

    readonly property var activeWallpaper:
        pluginApi?.pluginSettings?.activeWallpaper || {}

    onActiveWallpaperChanged: {
        if (Object.keys(activeWallpaper).length === 0) return
        var cmd = "killall linux-wallpaperengine; "
        for (var screen in activeWallpaper) {
            cmd += `linux-wallpaperengine -r ${screen} -b ${activeWallpaper[screen]} & `
        }
        setWallpaper.command = ["bash", "-c", cmd]
        setWallpaper.running = true
    }

    Process {
        id: setWallpaper
        command: []
    }
}
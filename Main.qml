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
        var cmd = "killall linux-wallpaperengine; linux-wallpaperengine "
        for (var screen in activeWallpaper) {
            cmd += `-r ${screen} -b ${activeWallpaper[screen]} `
        }
        setWallpaper.command = ["bash", "-c", cmd]
        setWallpaper.running = false
        setWallpaper.running = true
    }
    function initSettings() {
        if (!pluginApi.pluginSettings.activeWallpaper) {
            pluginApi.pluginSettings.activeWallpaper = {}
            pluginApi.saveSettings()
        }
        if (!pluginApi.pluginSettings.allMonitors) {
            pluginApi.pluginSettings.allMonitors = true
            pluginApi.saveSettings()
        }
    }

    onPluginApiChanged: {
        if (pluginApi) initSettings()
    }

    Process {
        id: setWallpaper
        command: []
    }
}
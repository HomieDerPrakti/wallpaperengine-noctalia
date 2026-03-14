import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets
import Qt.labs.folderlistmodel
import Quickshell.Io
import QtQml.Models
import QtQuick.Controls
import qs.Services.UI
import Quickshell
import QtCore
Item {
  id: root
  property var pluginApi: null
  property int currentScreenIndex: 0
  readonly property var geometryPlaceholder: panelContainer
  readonly property bool allowAttach: true
  property real contentPreferredWidth: 680 * Style.uiScaleRatio
  property real contentPreferredHeight: 540 * Style.uiScaleRatio
  readonly property string homeDir: StandardPaths.writableLocation(StandardPaths.HomeLocation)
  property string steamPath: ""
  property string wpEnginePath: steamPath + "/steamapps/workshop/content/431960/"
  anchors.fill: parent
  Rectangle {
    id: panelContainer
    anchors.fill: parent
    color: "transparent"
    ColumnLayout {
      id: "topColumn"
      spacing: Style.marginL
      anchors {
        fill: parent
        margins: Style.marginL
      }
      Rectangle {
        id: "settingsBox"
        Layout.fillWidth: true
        Layout.fillHeight: false
        Layout.preferredHeight: 150 * Style.uiScaleRatio
        color: Color.mSurfaceVariant
        radius: Style.radiusL

        ColumnLayout {
          id: "settingsColumn"
          anchors.fill: parent
          spacing: Style.marginS
          NText {
            text: "Wallpaper Engine"
            Layout.leftMargin: Style.marginL
            Layout.rightMargin: Style.marginL
            Layout.topMargin: Style.marginS
            pointSize: Style.fontSizeXL
            color: Color.mOnSurface
          }
          NDivider {
            Layout.fillWidth: true
          }
          NToggle {
            label: "Apply to all Monitors"
            description: "Apply to all Monitors"
            checked: pluginApi.pluginSettings.allMonitors
            onToggled: checked => { 
              pluginApi.pluginSettings.allMonitors = checked
              pluginApi.saveSettings()
            }
            Layout.fillWidth: true
            Layout.leftMargin: Style.marginL
            Layout.rightMargin: Style.marginL
            Layout.bottomMargin: pluginApi.pluginSettings.allMonitors ? Style.marginS : 0
          }
          NTabBar {
            id: screenTabBar
            visible: (!pluginApi.pluginSettings.allMonitors)
            Layout.fillWidth: true
            currentIndex: currentScreenIndex
            onCurrentIndexChanged: currentScreenIndex = currentIndex
            spacing: Style.marginM
            distributeEvenly: true
            Layout.leftMargin: Style.marginL
            Layout.rightMargin: Style.marginL
            Layout.bottomMargin: Style.marginS

            Repeater {
              model: Quickshell.screens
              NTabButton {
                required property var modelData
                required property int index
                text: modelData.name || `Screen ${index + 1}`
                tabIndex: index
                checked: {
                  screenTabBar.currentIndex === index;
                }
              }
            }
          }
        }
      }
      Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Color.mSurfaceVariant
        radius: Style.radiusL
        NGridView {
          id: "wallpaperGridView"
          anchors {
            fill: parent
            margins: Style.marginL
          }
          // anchors.fill: parent
          // anchors.margins: Style.marginL
          property int columns: Math.max(1, Math.floor(availableWidth / 300));
          property int itemSize: Math.floor(availableWidth / columns)
          cellWidth: itemSize
          cellHeight: Math.floor(itemSize * (9/16))
          model: wallpapersFolderModel
          delegate: ColumnLayout {
            required property int index
            readonly property string wp_id: wallpapersFolderModel.get(index, "fileName")
            
            readonly property string basePath: root.wpEnginePath + wp_id + "/"
            id: "wallpaperItem"
            height: wallpaperGridView.cellHeight
            width: wallpaperGridView.cellWidth
            FileView {
              id: jsonFile
              path: Qt.resolvedUrl(basePath + "project.json")
              blockLoading: true
            }
            readonly property var jsonData: JSON.parse(jsonFile.text())
            readonly property string title: jsonData.title
            readonly property string previewPath: basePath + jsonData.preview
            Item {
              id: "imageContainer"
              Layout.fillHeight: true
              Layout.fillWidth: true
              Layout.margins: mouseArea.containsMouse ? Style.marginS : Style.marginL
              NImageRounded {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                radius: Style.radiusL
                imagePath: previewPath
                imageFillMode: Image.PreserveAspectCrop
                borderColor: mouseArea.containsMouse ? "#fff" : "#000"
                borderWidth: 2
              }
              MouseArea {
                id: mouseArea
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                  ToastService.showNotice("wallpaper: " + wallpaperItem.wp_id + " " + wallpaperItem.title)
                  if (pluginApi.pluginSettings.allMonitors) {
                    for (var i = 0; i < Quickshell.screens.length; i++) {
                      root.saveWallpaper(wallpaperItem.wp_id, Quickshell.screens[i].name)
                    }
                  } else {
                    root.saveWallpaper(wallpaperItem.wp_id, Quickshell.screens[screenTabBar.currentIndex].name)
                  }
                }
              }
              Component.onCompleted: {
                console.log("wp_id:", wp_id, "previewPath:", previewPath)
              }
            }
            Rectangle {
              Layout.fillWidth: true
              color: "transparent"
              Layout.preferredHeight: 20 * Style.uiScaleRatio
              NText {
                anchors.centerIn: parent
                text: title
                color: Color.mOnSurface
                pointSize: Style.fontSizeS
              }
            }
          }
        }
      }
    }
  }
  FolderListModel {
    id: wallpapersFolderModel
    folder: Qt.resolvedUrl(root.wpEnginePath)
    showFiles: false
    showDirs: true
  }
  function saveWallpaper(wpId, screen) {
    var current = pluginApi.pluginSettings.activeWallpaper || {}
    var updated = Object.assign({}, current)  // create a new object
    updated[screen] = wpId
    pluginApi.pluginSettings.activeWallpaper = updated  // assign new object
    pluginApi.saveSettings()
  }
  function findSteamPath() {
    var defaultPaths = [
        homeDir + "/.local/share/Steam",
        homeDir + "/.steam/steam",
        homeDir + "/.steam/root",
        homeDir + "/.var/app/com.valvesoftware.Steam/.local/share/Steam",
        homeDir + "/.var/app/com.valvesoftware.Steam/.steam/steam",
        homeDir + "/snap/steam/common/.local/share/Steam",
        homeDir + "/snap/steam/common/.steam/steam"
    ]

    for (var i = 0; i < defaultPaths.length; i++) {
        pathChecker.path = defaultPaths[i] + "/steam.sh"
        if (pathChecker.text() !== "") {
            return defaultPaths[i]
        }
    }
    return ""
  }

  FileView {
    id: pathChecker
    blockLoading: true
  }

  Component.onCompleted: {
    steamPath = findSteamPath()
  }
}
import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets
import Qt.labs.folderlistmodel
import Quickshell.Io
import QtQml.Models
import QtQuick.Controls
Item {
  id: root
  property var pluginApi: null
  readonly property var geometryPlaceholder: panelContainer
  readonly property bool allowAttach: true
  property real contentPreferredWidth: 680 * Style.uiScaleRatio
  property real contentPreferredHeight: 540 * Style.uiScaleRatio
  anchors.fill: parent
  Rectangle {
    id: panelContainer
    anchors.fill: parent
    color: "transparent"
    ColumnLayout {
      id: "gridWrapper"
      spacing: Style.marginL
      anchors {
        fill: parent
        margins: Style.marginL
      }
      Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: false
        Layout.preferredHeight: 100 * Style.uiScaleRatio
        color: Color.mSurfaceVariant
        radius: Style.radiusL
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
            readonly property string basePath: "/home/julian/.local/share/Steam/steamapps/workshop/content/431960/" + wp_id + "/"
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
              }
              Component.onCompleted: {
                console.log("wp_id:", wp_id, "previewPath:", previewPath)
              }
            }
            Rectangle {
              Layout.fillWidth: true
              Layout.preferredHeight: 20 * Style.uiScaleRatio
              color: "transparent"
              NText {
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
    folder: "file:///home/julian/.local/share/Steam/steamapps/workshop/content/431960"
    showFiles: false
    showDirs: true
  }
}
import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root

  // Plugin API (injected by PluginPanelSlot)
  property var pluginApi: null

  // SmartPanel properties (required for panel behavior)
  readonly property var geometryPlaceholder: panelContainer
  readonly property bool allowAttach: true

  // Preferred dimensions
  property real contentPreferredWidth: 680 * Style.uiScaleRatio
  property real contentPreferredHeight: 540 * Style.uiScaleRatio

  anchors.fill: parent

  Rectangle {
    id: panelContainer
    anchors.fill: parent
    color: "transparent"
    RowLayout {
      anchors {
        fill: parent
        margins: Style.marginL
      }
      spacing: Style.marginL
      ColumnLayout {
        anchors {
          margins: Style.marginL
        }
        spacing: Style.marginL

        Rectangle {
          color: Color.mSurfaceVariant
          Layout.fillWidth: true
          Layout.fillHeight: true
          radius: Style.radiusL
          anchors.fill: parent


          NText {
            text: "placeholder"
            color: Style.mOnSurface
            pointSize: Style.fontSizeM
          }
        }
      }
      ColumnLayout {
        anchors {
          margins: Style.marginL
        }
        spacing: Style.marginL
        Rectangle {
          color: Color.mSurfaceVariant
          Layout.fillHeight: true
          Layout.fillWidth: true
          radius: Style.radiusL

          NText {
            text: "placeholder2"
            color: Style.mOnSurface
            pointSize: Style.fontSizeM
          }
        }
        Rectangle {
          color: Color.mSurfaceVariant
          Layout.fillHeight: true
          Layout.fillWidth: true
          radius: Style.radiusL

          NText {
            text: "placeholder3"
            color: Style.mOnSurface
            pointSize: Style.fontSizeM
          }
        }
      }
    }
  }
}
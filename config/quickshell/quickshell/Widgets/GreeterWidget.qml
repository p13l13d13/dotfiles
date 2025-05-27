pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell

import "../Data/" as Dat

RowLayout {
  id: root

  spacing: 10

  Rectangle {
    id: informationREct

    Layout.fillHeight: true
    Layout.fillWidth: true
    color: Dat.Colors.surface_container
    radius: 20

    Text {
      anchors.centerIn: parent
      color: Dat.Colors.on_surface
      font.pointSize: 14
      text: "Hello cutie"
    }
  }
}

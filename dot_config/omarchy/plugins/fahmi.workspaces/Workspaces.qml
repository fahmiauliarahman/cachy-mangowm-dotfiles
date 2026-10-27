import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

  // Pac-Man is drawn rather than typed: the Nerd Font's pac-man glyph is all
  // mouth at 14px, and a drawn shape keeps reading as Pac-Man at any bar size
  // and under any font `omarchy font set` picks.
  readonly property real pelletSize: 8
  readonly property real pacSize: 10
  readonly property real mouthAngle: 55
  readonly property color holeColor: bar ? bar.background : Color.background

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }

    return null
  }

  function workspaceIds() {
    var ids = [1, 2, 3, 4, 5]
    var values = Hyprland.workspaces.values

    for (var i = 0; i < values.length; i++) {
      var id = values[i].id
      if (id > 0 && id <= 10 && ids.indexOf(id) === -1) ids.push(id)
    }

    ids.sort(function(left, right) { return left - right })
    return ids
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.workspaceIds().length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.workspaceIds()

      WidgetButton {
        id: slot

        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData

        bar: root.bar
        // Non-breaking space keeps the button visible and interactive; the
        // real artwork is the children below.
        text: "\u00A0"
        labelVisible: false
        dimmed: !focused && !occupied
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(20)
        fixedHeight: root.barSize
        onPressed: function() { root.focusWorkspace(modelData) }

        Rectangle {
          anchors.centerIn: parent
          visible: !slot.focused
          width: root.pelletSize
          height: width
          radius: width / 2
          color: slot.foreground
        }

        Item {
          id: pacman
          anchors.centerIn: parent
          visible: slot.focused
          width: root.pacSize
          height: width

          Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            antialiasing: true

            ShapePath {
              fillColor: slot.foreground

              PathAngleArc {
                centerX: pacman.width / 2
                centerY: pacman.height / 2
                radiusX: pacman.width / 2
                radiusY: pacman.height / 2
                startAngle: root.mouthAngle / 2
                sweepAngle: 360 - root.mouthAngle
              }

              PathLine {
                x: pacman.width / 2
                y: pacman.height / 2
              }
            }
          }

          Rectangle {
            width: pacman.width * 0.15
            height: width
            radius: width / 2
            color: root.holeColor
            x: pacman.width * 0.42
            y: pacman.height * 0.19
          }
        }
      }
    }
  }
}

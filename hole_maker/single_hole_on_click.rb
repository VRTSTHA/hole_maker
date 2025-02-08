require_relative 'core'

module HoleMaker
  module SingleHoleOnClick
    def self.create
      model = Sketchup.active_model
      selection = model.selection

      if selection.empty?
        UI.messagebox("Please select an object to proceed.")
        return
      end

      prompts = ["Radius:", "Thickness:"]
      defaults = ["6", "10"]
      input = UI.inputbox(prompts, defaults, "Single Hole on Click")
      return unless input

      radius, thickness = HoleMaker::Utils.parse_single_hole_on_click_input(input)
      model.select_tool(SingleHoleOnClickTool.new(radius, thickness))
    end

    class SingleHoleOnClickTool
      def initialize(radius, thickness)
        @radius = radius
        @thickness = thickness
      end

      def activate(view)
        view.tooltip = "Click on the face to create a hole."
        Sketchup.status_text = "Click on the face to create a hole."
      end

      def onLButtonDown(flags, x, y, view)
        input_point = Sketchup::InputPoint.new
        input_point.pick(view, x, y)
        point = input_point.position
        face = input_point.face

        if face && point
          intersection_point = point
          circle_face = HoleMaker::Utils.add_circle(intersection_point, face, Sketchup.active_model.selection, @radius)
          HoleMaker::Utils.push_pull_face(circle_face, @thickness)
          Sketchup.status_text = "Click on the face to create another hole."
        else
          view.tooltip = "Please click on a valid face."
          Sketchup.status_text = "Please click on a valid face."
        end
      end

      def onMouseMove(flags, x, y, view)
        input_point = Sketchup::InputPoint.new
        input_point.pick(view, x, y)
        view.tooltip = "Click on a face to create a hole."
        Sketchup.status_text = "Click on a face to create a hole."
        view.invalidate if input_point.display?
      end

      def draw(view)
        input_point = Sketchup::InputPoint.new
        input_point.draw(view)
      end

      def deactivate(view)
        view.tooltip = ""
        Sketchup.status_text = ""
        view.invalidate
      end
    end
  end
end
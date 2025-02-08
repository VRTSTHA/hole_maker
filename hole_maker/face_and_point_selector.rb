module HoleMaker
  class FaceAndPointSelector
    def initialize(face_callback, point_callback)
      @face_callback = face_callback
      @point_callback = point_callback
      @selecting_face = true
      @face_input_point = Sketchup::InputPoint.new
      @point_input_point = Sketchup::InputPoint.new
    end

    def activate(view)
      view.tooltip = "Click on a face to select it."
      Sketchup.status_text = "Step 1: Click on a face to select it."
    end

    def onLButtonDown(flags, x, y, view)
      if @selecting_face
        # Pick the face without snapping
        @face_input_point.pick(view, x, y)
        face = @face_input_point.face
        if face
          @face_callback.call(face)
          @selecting_face = false
          view.tooltip = "Face selected. Now click a reference point on the face."
          Sketchup.status_text = "Step 2: Click a reference point on the face."
        else
          view.tooltip = "Please select a valid face."
          Sketchup.status_text = "Please click on a valid face."
        end
      else
        # Pick the reference point with snapping
        @point_input_point.pick(view, x, y)
        point = @point_input_point.position
        if point
          @point_callback.call(point)
          @selecting_face = true  # Reset to allow selecting another face
          view.tooltip = "Click on a face to select it."
          Sketchup.status_text = "Click on a face to select it."
        else
          view.tooltip = "Please select a valid point."
          Sketchup.status_text = "Please click on a valid point."
        end
      end
    end

    def onMouseMove(flags, x, y, view)
      if @selecting_face
        # Pick the face without snapping
        @face_input_point.pick(view, x, y)
        view.tooltip = "Click on a face to select it."
        Sketchup.status_text = "Step 1: Click on a face to select it."
        view.invalidate if @face_input_point.display?
      else
        # Pick the reference point with snapping
        @point_input_point.pick(view, x, y)
        view.tooltip = @point_input_point.tooltip
        Sketchup.status_text = "Step 2: Click a reference point on the face."
        view.invalidate if @point_input_point.display?
      end
    end

    def draw(view)
      if @selecting_face
        @face_input_point.draw(view)
      else
        @point_input_point.draw(view)
      end
    end

    def deactivate(view)
      view.tooltip = ""
      Sketchup.status_text = ""
      view.invalidate
    end
  end
end
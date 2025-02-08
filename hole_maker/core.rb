module HoleMaker
  module Utils
    def self.select_face_and_point(&block)
      model = Sketchup.active_model
      tool = HoleMaker::FaceAndPointSelector.new(
        ->(face) { @selected_face = face },
        ->(point) { block.call(@selected_face, point) if @selected_face }
      )
      model.select_tool(tool)
    end

    def self.get_face_plane(face)
      normal = face.normal
      if normal.parallel?(Geom::Vector3d.new(0, 0, 1))
        'XY'
      elsif normal.parallel?(Geom::Vector3d.new(0, 1, 0))
        'XZ'
      elsif normal.parallel?(Geom::Vector3d.new(1, 0, 0))
        'YZ'
      else
        UI.messagebox("Face is not aligned with XY, XZ, or YZ plane.")
        nil
      end
    end

    def self.plane_message(plane)
      case plane
      when 'XY' then 'Red Green face selected'
      when 'XZ' then 'Red Blue face selected'
      when 'YZ' then 'Blue Green face selected'
      else 'Unknown plane selected'
      end
    end

    def self.single_hole_input_prompts_and_defaults(plane)
      case plane
      when 'XY'
        [["X Distance:", "Y Distance:", "Radius:", "Thickness:"], ["10", "10", "6", "10"]]
      when 'XZ'
        [["X Distance:", "Z Distance:", "Radius:", "Thickness:"], ["10", "10", "6", "10"]]
      when 'YZ'
        [["Y Distance:", "Z Distance:", "Radius:", "Thickness:"], ["10", "10", "6", "10"]]
      end
    end

    def self.linear_pattern_input_prompts_and_defaults(plane)
      case plane
      when 'XY'
        [["X Distance:", "Y Distance:", "Radius:", "Thickness:", "Number of Holes:", "Hole Direction:", "Distance Between Holes:"],
         ["10", "10", "6", "10", "1", "+Red", "20"],
         ["", "", "", "", "", "+Red|+Green|-Red|-Green", ""]]
      when 'XZ'
        [["X Distance:", "Z Distance:", "Radius:", "Thickness:", "Number of Holes:", "Hole Direction:", "Distance Between Holes:"],
         ["10", "10", "6", "10", "1", "+Red", "20"],
         ["", "", "", "", "", "+Red|+Blue|-Red|-Blue", ""]]
      when 'YZ'
        [["Y Distance:", "Z Distance:", "Radius:", "Thickness:", "Number of Holes:", "Hole Direction:", "Distance Between Holes:"],
         ["10", "10", "6", "10", "1", "+Green", "20"],
         ["", "", "", "", "", "+Green|+Blue|-Green|-Blue", ""]]
      end
    end

    def self.parse_single_hole_input(plane, input)
      x_distance = (plane == 'YZ') ? 0 : Sketchup.parse_length(input[0])
      y_distance = (plane == 'XZ' || plane == 'YZ') ? Sketchup.parse_length(input[0]) : Sketchup.parse_length(input[1])
      z_distance = (plane == 'XY') ? 0 : Sketchup.parse_length(input[1])
      radius = Sketchup.parse_length(input[2])
      thickness = Sketchup.parse_length(input[3])
      [x_distance, y_distance, z_distance, radius, thickness]
    end

    def self.parse_linear_pattern_input(plane, input)
      x_distance = (plane == 'YZ') ? 0 : Sketchup.parse_length(input[0])
      y_distance = (plane == 'XZ' || plane == 'YZ') ? Sketchup.parse_length(input[0]) : Sketchup.parse_length(input[1])
      z_distance = (plane == 'XY') ? 0 : Sketchup.parse_length(input[1])
      radius = Sketchup.parse_length(input[2])
      thickness = Sketchup.parse_length(input[3])
      num_holes = input[4].to_i
      direction = input[5]
      distance_between_holes = Sketchup.parse_length(input[6])
      [x_distance, y_distance, z_distance, radius, thickness, num_holes, direction, distance_between_holes]
    end

    def self.parse_rectangular_pattern_input(plane, input)
      x_distance = (plane == 'YZ') ? 0 : Sketchup.parse_length(input[0])
      y_distance = (plane == 'XZ' || plane == 'YZ') ? Sketchup.parse_length(input[0]) : Sketchup.parse_length(input[1])
      z_distance = (plane == 'XY') ? 0 : Sketchup.parse_length(input[1])
      radius = Sketchup.parse_length(input[2])
      thickness = Sketchup.parse_length(input[3])
      length = Sketchup.parse_length(input[4])
      width = Sketchup.parse_length(input[5])
      [x_distance, y_distance, z_distance, radius, thickness, length, width]
    end

    def self.parse_single_hole_on_click_input(input)
      radius = Sketchup.parse_length(input[0])
      thickness = Sketchup.parse_length(input[1])
      [radius, thickness]
    end

    def self.calculate_rectangle_vertices(reference_point, length, width, plane)
      x, y, z = reference_point.to_a
      vertices = []

      case plane
      when 'XY'
        vertices << Geom::Point3d.new(x, y, z)
        vertices << Geom::Point3d.new(x + length, y, z)
        vertices << Geom::Point3d.new(x, y + width, z)
        vertices << Geom::Point3d.new(x + length, y + width, z)
      when 'XZ'
        vertices << Geom::Point3d.new(x, y, z)
        vertices << Geom::Point3d.new(x + length, y, z)
        vertices << Geom::Point3d.new(x, y, z + width)
        vertices << Geom::Point3d.new(x + length, y, z + width)
      when 'YZ'
        vertices << Geom::Point3d.new(x, y, z)
        vertices << Geom::Point3d.new(x, y + length, z)
        vertices << Geom::Point3d.new(x, y, z + width)
        vertices << Geom::Point3d.new(x, y + length, z + width)
      end

      vertices
    end

    def self.generate_guidelines(face, reference_point, x_distance, y_distance, z_distance)
      plane = self.get_face_plane(face)
      x, y, z = reference_point.to_a

      case plane
      when 'XY'
        Geom::Point3d.new(x + x_distance, y + y_distance, z)
      when 'XZ'
        Geom::Point3d.new(x + x_distance, y, z + z_distance)
      when 'YZ'
        Geom::Point3d.new(x, y + y_distance, z + z_distance)
      end
    end

    def self.create_hole(face, reference_point, x_distance, y_distance, z_distance, radius, thickness)
      intersection_point = self.generate_guidelines(face, reference_point, x_distance, y_distance, z_distance)
      circle_face = self.add_circle(intersection_point, face, Sketchup.active_model.selection, radius)
      self.push_pull_face(circle_face, thickness)
    end

    def self.generate_holes(face, reference_point, x_distance, y_distance, z_distance, radius, thickness, num_holes, direction, distance_between_holes)
      direction_vector = case direction
                         when "+Red" then Geom::Vector3d.new(1, 0, 0)
                         when "-Red" then Geom::Vector3d.new(-1, 0, 0)
                         when "+Green" then Geom::Vector3d.new(0, 1, 0)
                         when "-Green" then Geom::Vector3d.new(0, -1, 0)
                         when "+Blue" then Geom::Vector3d.new(0, 0, 1)
                         when "-Blue" then Geom::Vector3d.new(0, 0, -1)
                         else
                           UI.messagebox("Invalid direction selected.")
                           return
                         end

      model = Sketchup.active_model
      model.start_operation('Add Linear Pattern', true)

      num_holes.times do |i|
        offset = direction_vector.clone
        offset.length = i * distance_between_holes
        new_reference_point = reference_point.offset(offset)
        self.create_hole(face, new_reference_point, x_distance, y_distance, z_distance, radius, thickness)
      end

      model.commit_operation
    end

    def self.add_circle(intersection_point, face, selection, radius)
      model = Sketchup.active_model
      selected_object = selection.first
      return unless selected_object.is_a?(Sketchup::Group) || selected_object.is_a?(Sketchup::ComponentInstance)
      model.start_operation('Add Circle', true)
      entities = selected_object.definition.entities
      local_intersection_point = intersection_point.transform(selected_object.transformation.inverse)
      normal = face.normal
      circle = entities.add_circle(local_intersection_point, normal, radius)
      circle.each { |edge| edge.find_faces }
      circle_face = circle.first.faces.first
      model.commit_operation
      circle_face
    end

    def self.push_pull_face(face, thickness)
      return unless face
      model = Sketchup.active_model
      model.start_operation('Push/Pull Face', true)
      face.pushpull(-thickness)
      model.commit_operation
    end
  end
end
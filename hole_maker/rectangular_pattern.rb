require_relative 'core'

module HoleMaker
  module RectangularPattern
    def self.create
      HoleMaker::Utils.select_face_and_point do |face, reference_point|
        plane = HoleMaker::Utils.get_face_plane(face)
        return unless plane

        plane_message = HoleMaker::Utils.plane_message(plane)
        prompts = ["X Distance:", "Y Distance:", "Radius:", "Thickness:", "Length:", "Width:"]
        defaults = ["10", "10", "6", "10", "50", "30"]

        input = UI.inputbox(prompts, defaults, plane_message)
        return unless input

        x_distance, y_distance, z_distance, radius, thickness, length, width = HoleMaker::Utils.parse_rectangular_pattern_input(plane, input)
        vertices = HoleMaker::Utils.calculate_rectangle_vertices(reference_point, length, width, plane)
        vertices.each do |vertex|
          HoleMaker::Utils.create_hole(face, vertex, x_distance, y_distance, z_distance, radius, thickness)
        end
      end
    end
  end
end
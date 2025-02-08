require_relative 'core'

module HoleMaker
  module LinearPattern
    def self.create
      HoleMaker::Utils.select_face_and_point do |face, reference_point|
        plane = HoleMaker::Utils.get_face_plane(face)
        return unless plane

        plane_message = HoleMaker::Utils.plane_message(plane)
        prompts, defaults, dropdowns = HoleMaker::Utils.linear_pattern_input_prompts_and_defaults(plane)

        input = UI.inputbox(prompts, defaults, dropdowns, plane_message)
        return unless input

        x_distance, y_distance, z_distance, radius, thickness, num_holes, direction, distance_between_holes = HoleMaker::Utils.parse_linear_pattern_input(plane, input)
        HoleMaker::Utils.generate_holes(face, reference_point, x_distance, y_distance, z_distance, radius, thickness, num_holes, direction, distance_between_holes)
      end
    end
  end
end
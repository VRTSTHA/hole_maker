require_relative 'core'

module HoleMaker
  module SingleHole
    def self.create
      HoleMaker::Utils.select_face_and_point do |face, reference_point|
        plane = HoleMaker::Utils.get_face_plane(face)
        return unless plane

        plane_message = HoleMaker::Utils.plane_message(plane)
        prompts, defaults = HoleMaker::Utils.single_hole_input_prompts_and_defaults(plane)

        input = UI.inputbox(prompts, defaults, plane_message)
        return unless input

        x_distance, y_distance, z_distance, radius, thickness = HoleMaker::Utils.parse_single_hole_input(plane, input)
        HoleMaker::Utils.create_hole(face, reference_point, x_distance, y_distance, z_distance, radius, thickness)
      end
    end
  end
end
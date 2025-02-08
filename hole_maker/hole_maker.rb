require_relative 'core'
require_relative 'single_hole'
require_relative 'linear_pattern'
require_relative 'rectangular_pattern'
require_relative 'single_hole_on_click'
require_relative 'face_and_point_selector'

module HoleMaker
  def self.activate
    if Sketchup.active_model.selection.empty?
      UI.messagebox("Please select an object to proceed.")
      return
    end

    patterns = ["Single Hole", "Linear Pattern", "Rectangular Pattern", "Single Hole on Click"]
    choice = UI.inputbox(["Select Hole Pattern:"], [patterns[0]], [patterns.join("|")], "Hole Pattern Selection")
    return unless choice

    case choice[0]
    when "Single Hole"
      HoleMaker::SingleHole.create
    when "Linear Pattern"
      HoleMaker::LinearPattern.create
    when "Rectangular Pattern"
      HoleMaker::RectangularPattern.create
    when "Single Hole on Click"
      HoleMaker::SingleHoleOnClick.create
    else
      UI.messagebox("Invalid selection.")
    end
  end

  unless file_loaded?(__FILE__)
    menu = UI.menu('Plugins')
    menu.add_item('Hole Maker') { HoleMaker.activate }
    file_loaded(__FILE__)
  end
end
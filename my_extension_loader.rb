require 'sketchup.rb'
require 'extensions.rb'

module MyExtension
  unless file_loaded?(__FILE__)
    ex = SketchupExtension.new('Hole Maker', 'hole_maker/hole_maker.rb')
    ex.description = 'Creates holes in a selected object using different patterns'
    ex.version     = '1.0.0'
    ex.creator     = 'Bharat Shrestha'
    ex.copyright   = '2025, Bharat Shrestha'
    Sketchup.register_extension(ex, true)
    file_loaded(__FILE__)
  end
end
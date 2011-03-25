require "rubygems"
require "rake"
require "chocbomb"

ChocBomb::Configuration.new do |s|
  s.minimum_osx_version = "10.6.0"
  # Custom DMG
  s.background_file = "background.png"
  s.app_icon_position = [140, 330]
  s.applications_icon_position = [370, 330]
  s.link 'http://graphviz.org', :name => "Graphviz", :position => [370, 70]
end

require "rubygems"
require "rake"

require "choctop"

ChocTop::Configuration.new do |s|
  # Remote upload target (set host if not same as Info.plist['SUFeedURL'])
  s.host = 'algorithmique.net'
  s.base_url = "http://#{s.host}/leonhard"
  s.remote_dir = '/path/to/upload/root/of/app'

  # Custom DMG
  s.background_file = "background.png"
  s.app_icon_position = [140, 300]
  s.applications_icon_position =  [370, 300]
  # s.volume_icon = "dmg.icns"
  # s.applications_icon = "appicon.icns" # or "appicon.png"
end

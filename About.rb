# AboutController.rb
# Leonhard
#
# Created by greg on 24/02/11.
# Copyright 2011 __MyCompanyName__. All rights reserved.

class About
  attr_accessor :leonhard_version
  attr_accessor :macruby_version
  attr_accessor :aboutWindow
  attr_accessor :mainWindow
  
  def awakeFromNib
    @leonhard_version.setStringValue(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion"))
    @macruby_version.setStringValue(MACRUBY_VERSION + " (" + RUBY_VERSION + ")")
    @aboutWindow.setReleasedWhenClosed(false)
    @aboutWindow.setDelegate(self)
  end
  
  def windowShouldClose(sender)
    NSApp.stopModal()
    return true
  end
  
  def showAboutWindow(sender)
    @aboutWindow.makeKeyAndOrderFront(sender)
    NSApp.runModalForWindow(@aboutWindow)
	end
end

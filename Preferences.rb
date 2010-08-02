# Preferences.rb
# Leonhard
#
# Created by greg on 28/07/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

class Preferences
  attr_accessor :mainWindow
  attr_accessor :preferencesWindow
  attr_accessor :graphVizPath
  attr_accessor :autoGenerate
  attr_accessor :syntaxHighlighting

  def initialize
  end
  
  def awakeFromNib
    # Load preferences
		userDefaultsValuesPath=NSBundle.mainBundle.pathForResource("UserDefaults", ofType:"plist")
		userDefaultsValuesDict=NSDictionary.dictionaryWithContentsOfFile(userDefaultsValuesPath)

		@userDefaultsPrefs = NSUserDefaults.standardUserDefaults
		@userDefaultsPrefs.registerDefaults(userDefaultsValuesDict)
    
    # Set preferences values
    @graphVizPath.stringValue = @userDefaultsPrefs.valueForKey("GraphVizPath").clone
    @autoGenerate.state = @userDefaultsPrefs.valueForKey("Autogenerate")
    @syntaxHighlighting.state = @userDefaultsPrefs.valueForKey("SyntaxHighlighting")
  end
  
  def closePreferencesWindow(sender)
    @userDefaultsPrefs.setObject(@graphVizPath.stringValue(), forKey: "GraphVizPath")
    @userDefaultsPrefs.setObject((@autoGenerate.state == 1), forKey: "Autogenerate")
    @userDefaultsPrefs.setObject((@syntaxHighlighting.state == 1), forKey: "SyntaxHighlighting")
    @userDefaultsPrefs.synchronize
        
		NSApp.endSheet(@preferencesWindow)
		@preferencesWindow.orderOut(sender)
	end
  
  def showPreferencesWindow(sender)
		NSApp.beginSheet(@preferencesWindow, modalForWindow:@mainWindow, modalDelegate:nil, didEndSelector:nil, contextInfo:nil)
	end
  
  def autogenerate?
    @userDefaultsPrefs.valueForKey("Autogenerate")
  end
  
  def syntaxHighlighting?
    @userDefaultsPrefs.valueForKey("SyntaxHighlighting")
  end
  
  def gvPath
    @userDefaultsPrefs.valueForKey("GraphVizPath")
  end
end

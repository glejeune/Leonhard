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
  attr_accessor :autocomplete

  def initialize
  end
  
  def awakeFromNib
    # default preferences
		@userDefaultsPrefs = NSUserDefaults.standardUserDefaults()
    
    # Fragaria
    @userDefaultsPrefs.setObject(NSNumber.numberWithBool(true), forKey:"AutocompleteSuggestAutomatically")
    @userDefaultsPrefs.setObject(NSNumber.numberWithBool(true), forKey:"LineWrapNewDocuments")
    @userDefaultsPrefs.setObject(NSNumber.numberWithBool(true), forKey:"IndentWithSpaces")
    @userDefaultsPrefs.setObject(NSNumber.numberWithBool(false), forKey:"AutocompleteSuggestAutomatically")
    @userDefaultsPrefs.setObject(2, forKey:"TabWidth")
    @userDefaultsPrefs.setObject(2, forKey:"IndentWidth")
    @userDefaultsPrefs.setObject(NSArchiver.archivedDataWithRootObject(NSFont.fontWithName("Courier", size:13)), forKey:"TextFont")
    
    # Leonhard
    @userDefaultsPrefs.setObject("", forKey:"GraphVizPath")
    @userDefaultsPrefs.setObject(false, forKey:"Autogenerate")
    
    # Set preferences values
    @graphVizPath.stringValue = @userDefaultsPrefs.valueForKey("GraphVizPath").clone
    @autoGenerate.state = @userDefaultsPrefs.valueForKey("Autogenerate")
    @autocomplete.state = @userDefaultsPrefs.valueForKey("AutocompleteSuggestAutomatically")    
  end
  
  def closePreferencesWindow(sender)
    @userDefaultsPrefs.setObject(@graphVizPath.stringValue(), forKey: "GraphVizPath")
    @userDefaultsPrefs.setObject((@autoGenerate.state == 1), forKey: "Autogenerate")
    @userDefaultsPrefs.setObject(@autocomplete.state, forKey: "AutocompleteSuggestAutomatically")
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
  
  def gvPath
    @userDefaultsPrefs.valueForKey("GraphVizPath")
  end
end

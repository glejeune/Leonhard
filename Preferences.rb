# Preferences.rb
# Leonhard
#
# Created by greg on 28/07/10.
# Copyright 2010 Gregoire Lejeune. All rights reserved.

class Preferences
  attr_accessor :mainWindow
  attr_accessor :preferencesWindow
  attr_accessor :graphVizPath
  attr_accessor :autoGenerate
  attr_accessor :autocomplete
  attr_accessor :suuAutomaticallyChecksForUpdates
  attr_accessor :suuInterval
  attr_accessor :suuAutomaticallyDownloadsUpdates

  def initialize
    @suuIntervalsDef = {
      "Every hour" => 3600, 
      "Every day" => 86400,
      "Every week" => 604800, 
      "Every month" => 2592000
    }
  end
  
  def awakeFromNib
    # default preferences
		@userDefaultsPrefs = NSUserDefaults.standardUserDefaults()
    
    # Fragaria
    @userDefaultsPrefs.setObject(NSNumber.numberWithBool(true), forKey:"LineWrapNewDocuments")
    @userDefaultsPrefs.setObject(NSNumber.numberWithBool(true), forKey:"IndentWithSpaces")
    @userDefaultsPrefs.setObject(NSNumber.numberWithBool(false), forKey:"AutocompleteSuggestAutomatically") if @userDefaultsPrefs.valueForKey("AutocompleteSuggestAutomatically").nil?
    @userDefaultsPrefs.setObject(2, forKey:"TabWidth")
    @userDefaultsPrefs.setObject(2, forKey:"IndentWidth")
    @userDefaultsPrefs.setObject(NSArchiver.archivedDataWithRootObject(NSFont.fontWithName("Courier", size:13)), forKey:"TextFont")
    
    # Leonhard
    @userDefaultsPrefs.setObject("", forKey:"GraphVizPath") if @userDefaultsPrefs.valueForKey("GraphVizPath").nil?
    @userDefaultsPrefs.setObject(false, forKey:"Autogenerate") if @userDefaultsPrefs.valueForKey("Autogenerate").nil?
    
    # Set preferences values
    @graphVizPath.stringValue = @userDefaultsPrefs.valueForKey("GraphVizPath").clone
    @autoGenerate.state = @userDefaultsPrefs.valueForKey("Autogenerate")
    @autocomplete.state = @userDefaultsPrefs.valueForKey("AutocompleteSuggestAutomatically")
    
    # SUUpdater
    @suuAutomaticallyChecksForUpdates.state = SUUpdater.sharedUpdater.automaticallyChecksForUpdates
    @suuInterval.removeAllItems
    @suuInterval.addItemsWithTitles(@suuIntervalsDef.keys)
    @suuInterval.selectItemWithTitle(@suuIntervalsDef.invert[Integer(SUUpdater.sharedUpdater.updateCheckInterval)])
    @suuAutomaticallyDownloadsUpdates.state = SUUpdater.sharedUpdater.automaticallyDownloadsUpdates
  end
  
  def closePreferencesWindow(sender)
    @userDefaultsPrefs.setObject(@graphVizPath.stringValue(), forKey: "GraphVizPath")
    @userDefaultsPrefs.setObject((@autoGenerate.state == 1), forKey: "Autogenerate")
    @userDefaultsPrefs.setObject((@autocomplete.state == 1), forKey: "AutocompleteSuggestAutomatically")
    @userDefaultsPrefs.synchronize
    
    # SUU
    SUUpdater.sharedUpdater.setAutomaticallyChecksForUpdates(@suuAutomaticallyChecksForUpdates.state == 1)
    SUUpdater.sharedUpdater.setUpdateCheckInterval(@suuIntervalsDef[@suuInterval.titleOfSelectedItem])
    SUUpdater.sharedUpdater.setAutomaticallyDownloadsUpdates(@suuAutomaticallyDownloadsUpdates.state == 1)
    
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
  
  def [](x) 
    @userDefaultsPrefs.valueForKey(x)
  end  
end

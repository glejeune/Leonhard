# AppController.rb
# Leonhard
#
# Created by greg on 28/07/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

#require 'CodeViewDelegator'
#require 'GraphVizGenerator'

class AppController
  attr_accessor :mainWindow
  attr_accessor :preferences
  attr_accessor :pdfView
  attr_accessor :codeView
  attr_accessor :fragariaView
  attr_accessor :errorsView
  attr_accessor :interpretorMenu
  attr_accessor :fragaria

  def initialize
    @fileName = nil
    @lastSavedScript = nil
  end

  def awakeFromNib
  end
  
  def applicationDidFinishLaunching(aNotification)
    @fragaria = MGSFragaria.alloc.init
    
    @fragaria.setObject(NSNumber.numberWithBool(true), forKey:"isSyntaxColoured")
    @fragaria.setObject(NSNumber.numberWithBool(true), forKey:"showLineNumberGutter")
#    @fragaria.setObject(self, forKey:"MGSFODelegate")
	
    # define our syntax definition
    @fragaria.setObject("GraphViz", forKey:"syntaxDefinition")
    
    # embed editor in editView
    @fragaria.embedInView(@fragariaView)
    
    # Get the textview
    @codeView = @fragaria.objectForKey("firstTextView")
    
    # Set GraphVizGenerator
    @graphVizGenerator = GraphVizGenerator.new( @codeView, @errorsView, @pdfView, @preferences )
    @codeView.textStorage.delegate = CodeViewDelegator.new( @graphVizGenerator, @preferences )

    # Set default interpretor
    @graphVizGenerator.interpretor = "dot"
    @interpretorMenu.itemArray.each do |menuItem|
      menuItem.state = NSOffState unless menuItem.title == @graphVizGenerator.interpretor
    end

    loadDOTFile(@fileToOpen) if @fileToOpen
  end

  def application(sender, openFile:path)
    @fileToOpen = path
    return true
  end
  
  def regenerate(sender)
    @graphVizGenerator.regenerate(sender)
  end
  
  def getInterpreter(sender)
    @interpretorMenu.itemArray.each do |menuItem|
      menuItem.state = NSOffState
    end
    sender.state = NSOnState
    @graphVizGenerator.interpretor = sender.title
    regenerate(sender) if @preferences.autogenerate?
  end
  
  def saveAs(sender)
    panel = NSSavePanel.savePanel()
    ret = panel.runModal()
    if ret == NSFileHandlingPanelOKButton
      @fileName = panel.URL.path
      saveDOTFile()
    end
  end
  
  def save(sender)
    if @fileName.nil?
      saveAs(sender)
    else
      saveDOTFile()
    end
  end
  
  def saveDOTFile
    @lastSavedScript = self.codeView.textStorage.string.clone
    File.open(@fileName, "w").print( @lastSavedScript )
    
    # mainWindow title
    @mainWindow.title = "#{File.basename(@fileName)} - Leonhard"
  end

  def revertToSave(sender)
    unless @lastSavedScript.nil?
      # Set code
      @codeView.textStorage.mutableString.string = @lastSavedScript
      # Set default font
      # self.codeView.font = NSFont.fontWithName( "Courier", size:13 )
    end
  end

  def openFile(sender)
    panel = NSOpenPanel.openPanel()
    ret = panel.runModal()
    if ret == NSFileHandlingPanelOKButton
      loadDOTFile( panel.URL.path )
    end
  end

  def loadDOTFile( file )
    @fileName = file
    # Set code
    @lastSavedScript = File.open( @fileName ).read
    @codeView.textStorage.mutableString.string = @lastSavedScript.clone
    # Set default font
    # self.codeView.font = NSFont.fontWithName( "Courier", size:13 )
    
    # mainWindow title
    @mainWindow.title = "#{File.basename(@fileName)} - Leonhard"
  end
  
  def graphVizOnlineHelp(sender)
    NSWorkspace.sharedWorkspace.openURL(NSURL.URLWithString("http://www.graphviz.org/Documentation.php"))
  end

  def export(sender)
    panel = NSSavePanel.savePanel()
    ret = panel.runModal()
    if ret == NSFileHandlingPanelOKButton
      @graphVizGenerator.save( sender.title, panel.URL.path)
    end
  end

end

# XMLDocument.rb
# Leonhard
#
# Created by greg on 03/11/10.
# Copyright 2010 Grégoire Lejeune. All rights reserved.

require 'rexml/document'

class XMLDocument
  @oReXML
  @oGraph 
  @xNodeName
	@bShowText
	@bShowAttrs
  
  def dot
    @oGraph
  end
  
  private
  
  # 
  # Create a graph from a XML file
  # 
  def initialize(xFile)
    @xNodeName = "00000"
	  @bShowText = true
	  @bShowAttrs = true
  
    @oReXML = REXML::Document::new( File::new( xFile ) )
    @oGraph = "digraph XML {\n"
    _init( @oReXML.root() )
    @oGraph << "}\n"
  end
  
  def _init( oXMLNode ) #:nodoc:
    xLocalNodeName = @xNodeName.clone
    @xNodeName.succ!
    
    label = oXMLNode.name
    if oXMLNode.has_attributes? == true and @bShowAttrs == true
      label = "{ " + oXMLNode.name 
	
	    oXMLNode.attributes.each do |xName, xValue|
	      label << "| { #{xName} | #{xValue} } " 
	    end
	
	    label << "}"
	  end
	  @oGraph << "  #{xLocalNodeName}[label=\"#{label}\", color=\"blue\", shape=\"record\"];\n"
  
    ## Act: Search and add Text nodes
    if oXMLNode.has_text? == true and @bShowText == true
      xTextNodeName = xLocalNodeName.clone
      xTextNodeName << "111"
      
      xText = ""
      xSep = ""
      oXMLNode.texts().each do |l|
        x = l.value.chomp.strip
        if x.length > 0
          xText << xSep << x
          xSep = "\n"
        end
      end
  
      if xText.length > 0
    	  @oGraph << "  #{xTextNodeName}[label=\"#{xText}\", color=\"black\", shape=\"ellipse\"];\n"
    	  @oGraph << "  #{xLocalNodeName} -> #{xTextNodeName}\n"
      end
    end
  
    ## Act: Search and add attributs
    ## TODO
  
    oXMLNode.each_element( ) do |oXMLChild|
      xChildNodeName = _init( oXMLChild )
      @oGraph << "  #{xLocalNodeName} -> #{xChildNodeName}\n"
    end
  
    return( xLocalNodeName )
  end
end


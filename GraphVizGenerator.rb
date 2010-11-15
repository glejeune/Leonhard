# GraphVizGenerator.rb
# Leonhard
#
# Created by greg on 28/07/10.
# Copyright 2010 Gregoire Lejeune. All rights reserved.

require 'tempfile'
require 'fileutils'
require 'GVUtils'

class GraphVizGenerator
  include GVUtils
  
  attr_accessor :interpretor
  
  def initialize( codeView, errorsView, pdfView, preferences )
    @codeView = codeView
    @errorsView = errorsView
    @pdfView = pdfView
    @preferences = preferences
    @interpretor = "dot"
  end
  
  def save( format = "pdf", file = nil )
    t = Tempfile::open( File.basename(__FILE__) )
    t.print( @codeView.textStorage.mutableString )
    t.close
    
    dotFile = t.path
    outFile = dotFile+"."+format
    outFile = file unless file.nil?
    
    dotExe = unless @preferences.gvPath.strip.empty?
        File.join( @preferences.gvPath, @interpretor )
      else
        @interpretor
      end
    
    xCmd = "#{dotExe} -T#{format} -o#{outFile} #{dotFile}"
    output, errors = output_and_errors_from_command( xCmd )
    if errors.nil? or errors.strip.empty?
      @errorsView.textStorage.mutableString.string = "0 error!"
    else
      @errorsView.textStorage.mutableString.string = errors.gsub( dotFile, "" )
    end
    @errorsView.font = NSUnarchiver.unarchiveObjectWithData(@preferences["TextFont"]) 
    
    @pdfView.document = PDFDocument.alloc.initWithURL( NSURL.fileURLWithPath(outFile) ) if @file.nil?
    
    t.unlink
    FileUtils.rm_f( outFile ) if file.nil?
    save() unless file.nil?
  end
  
  def regenerate(sender)
    save()
  end
end
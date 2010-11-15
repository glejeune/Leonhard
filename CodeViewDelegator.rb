# SyntaxHighlighting.rb
# Leonhard
#
# Created by greg on 28/07/10.
# Copyright 2010 Gregoire Lejeune. All rights reserved.

class CodeViewDelegator
  def initialize( graphVizGenerator, preferences )
    @graphVizGenerator = graphVizGenerator
    @preferences = preferences
  end
  
  def textStorageDidProcessEditing(notification)
    @graphVizGenerator.regenerate(self) if @preferences.autogenerate?
  end
end

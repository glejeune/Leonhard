# SyntaxHighlighting.rb
# Leonhard
#
# Created by greg on 28/07/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

SH_NULL = nil
SH_STRING = NSColor.grayColor
SH_COMMENT = NSColor.colorWithCalibratedRed 0.09, :green => 0.62, :blue => 0.22, :alpha => 1
SH_RESERVED = NSColor.redColor
SH_CONST = NSColor.blueColor
SH_NUMBER = NSColor.orangeColor
SH_CLASSVAR = NSColor.colorWithCalibratedRed 0.45, :green => 0.12, :blue => 0.44, :alpha => 1

class CodeViewDelegator
  def initialize( graphVizGenerator, preferences )
    @graphVizGenerator = graphVizGenerator
    @preferences = preferences
    
    @words = %w{
			strict graph digraph node edge subgraph
		}
    @attributs = %w{
      Damping K URL arrowhead arrowsize arrowtail aspect bb bgcolor center charset clusterrank color 
      colorList colorscheme comment compound concentrate constraint decorate defaultdist dim dimen dir 
      diredgeconstraints bool distortion dpi edgeURL edgehref edgetarget edgetooltip epsilon esep pointf 
      fillcolor fixedsize fontcolor fontname fontnames fontpath fontsize group headURL headclip headhref 
      headlabel headport headtarget headtooltip height href id image imagescale label labelURL labelangle 
      labeldistance labelfloat labelfontcolor labelfontname labelfontsize labelhref labeljust labelloc 
      labeltarget labeltooltip landscape layer layers layersep layout len levels levelsgap lhead lheight lp 
      ltail lwidth margin pointf maxiter mclimit mindist minlen mode model mosek nodesep nojustify 
      normalize nslimit nslimit1 ordering orientation orientation outputorder overlap overlap_scaling pack 
      int packmode pad pointf page pointf pagedir pencolor penwidth peripheries pin pos splineType quadtree 
      quantum rank rankdir ranksep doubleList ratio rects regular remincross repulsiveforce resolution root 
      rotate samehead sametail samplepoints searchsize sep shape shapefile showboxes sides size skew 
      smoothing sortv splines string start style stylesheet tailURL tailclip tailhref taillabel tailport 
      tailtarget tailtooltip target string tooltip truecolor vertices viewport voro_margin weight width z
    }
  end
  
  def textStorageDidProcessEditing(notification)
    syntaxHighlight(notification) if @preferences.syntaxHighlighting?
    @graphVizGenerator.regenerate(self) if @preferences.autogenerate?
  end
  
  def syntaxHighlight(notification)
		textStorage = notification.object
		string = textStorage.string
		area = textStorage.editedRange
		length = string.length
		areamax = NSMaxRange(area)
		found = NSRange.new

		whiteSpaceSet = NSCharacterSet.characterSetWithCharactersInString "\n\t\ .(){}[]:|=;," # whitespaceAndNewlineCharacterSet
		
		start = string.rangeOfCharacterFromSet whiteSpaceSet,
			:options => NSBackwardsSearch,
			:range => NSMakeRange(0, area.location)
		if( start.location == NSNotFound )
			start.location = 0;
		else
			start.location = NSMaxRange(start);
		end
		
		_end = string.rangeOfCharacterFromSet whiteSpaceSet,
			:options => 0,
			:range => NSMakeRange(areamax, length - areamax)
		if( _end.location == NSNotFound )
			_end.location = length;
		end
		
		area = NSMakeRange(start.location, _end.location - start.location);
		return if area.length == 0 # bail early
		
		# remove the old colors
		textStorage.removeAttribute NSForegroundColorAttributeName, :range => area
		
		# add new colors
		while( area.length > 0 )
			# find the next word
			_end = string.rangeOfCharacterFromSet whiteSpaceSet,
				:options => 0,
				:range => area
			if _end.location == NSNotFound
				_end = found = area
			else
				found.length = _end.location - area.location
				found.location = area.location
			end
			
			word = string.substringWithRange found
			
			# color as necessary
			if @words.include?(word)
				textStorage.addAttribute NSForegroundColorAttributeName,
					:value => SH_RESERVED,
					:range => found
      elsif @attributs.include?(word)
				textStorage.addAttribute NSForegroundColorAttributeName,
					:value => SH_NUMBER,
					:range => found
#			elsif /^[A-Z]/.match word[0]
#				textStorage.addAttribute NSForegroundColorAttributeName,
#					:value => SH_CONST,
#					:range => found
#			elsif word[0] == "@"
#				textStorage.addAttribute NSForegroundColorAttributeName,
#					:value => SH_CLASSVAR,
#					:range => found
#			elsif /^[0-9_\.]*$/.match(word)
#				textStorage.addAttribute NSForegroundColorAttributeName,
#					:value => SH_NUMBER,
#					:range => found
			end
			
			# adjust our area
			areamax = NSMaxRange(_end)
			area.length -= areamax - area.location
			area.location = areamax
		end
		
		# Color string & comment	
		strFound = SH_NULL
		colorRange = NSRange.new

		(0...NSMaxRange(area)).each { |i|
			if string[i] == '"'
				if strFound == SH_NULL
					colorRange.location = i
					strFound = SH_STRING
				elsif strFound == SH_STRING
					colorRange.length = i - colorRange.location + 1
					textStorage.addAttribute NSForegroundColorAttributeName,
						:value => strFound,
						:range => colorRange
					strFound = SH_NULL
				end
			elsif string[i] == "/" and string[i+1] and string[i+1] == "/" and strFound == SH_NULL
				colorRange.location = i
				strFound = SH_COMMENT
			elsif string[i] == "\n" and strFound == SH_COMMENT
				colorRange.length = i - colorRange.location + 1
				textStorage.addAttribute NSForegroundColorAttributeName,
					:value => strFound,
					:range => colorRange
				strFound = SH_NULL
			end
		}
	end
end

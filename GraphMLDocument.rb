# GraphMLDocument.rb
# Leonhard
#
# Created by greg on 04/11/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

require 'rexml/document'

class GraphMLDocument
  attr_reader :attributs
  attr_accessor :graph

  DEST = {
    'node'  => [:nodes],
    'edge'  => [:edges],
    'graph' => [:graphs],
    'all'   => [:nodes, :edges, :graphs]
  }
  
  GTYPE = {
    'directed' => 'digraph',
    'undirected' => 'graph'
  }
  
  ETYPE = {
    'directed' => "->",
    'undirected' => "--"
  }
  
  def initialize( file_or_str )
    data = ((File.file?( file_or_str )) ? File::new(file_or_str) : file_or_str) 
    @xmlDoc = REXML::Document::new( data )
    @attributs = {
      :nodes => {},
      :edges => {},
      :graphs => {}
    }
    @graph = nil
    @current_attr = nil
    @current_node = nil
    @current_edge = nil
    @current_graph = nil
    @edge_type = nil
    @indent = 0
    
    parse( @xmlDoc.root )
  end
  
  def parse( node )
    send( node.name.to_sym, node )
  end
  
  def dot
    @graph
  end
  
  def graphml( node )
    node.each_element( ) do |child|
      send( "graphml_#{child.name}".to_sym, child )
    end
  end
  
  def graphml_key( node )
    id = node.attributes['id']
    @current_attr = {
      :name => node.attributes['attr.name'],
      :type => node.attributes['attr.type']
    }    
    DEST[node.attributes['for']].each do |d|
      @attributs[d][id] = @current_attr
    end
    
    node.each_element( ) do |child|
      begin
        send( "graphml_key_#{child.name}".to_sym, child )
      rescue NoMethodError => e
        raise "ERROR node #{child.name} can be child of graphml"
      end
    end
    
    @current_attr = nil
  end
  
  def graphml_key_default( node )
    @current_attr[:default] = node.texts()[-1].inspect
  end
  
  def graphml_graph( node )
    @current_node = nil
    
    if @current_graph.nil?
      @graph = "#{GTYPE[node.attributes['edgedefault']]} \"#{node.attributes['id']}\" {\n"
      @edge_type = ETYPE[node.attributes['edgedefault']]
      @current_graph = @graph
      previous_graph = @graph
      @indent += 2
    else
      previous_graph = @current_graph      
      @current_graph << " "*@indent + "subgraph \"#{node.attributes['id']}\" {\n"
      @indent += 2
    end
    
    @attributs[:graphs].each do |id, data|
      @current_graph << " "*@indent + "#{data[:name]} = #{data[:default]};\n" if data.has_key?(:default)
    end
    
    sep = " "*@indent + "node["
    @attributs[:nodes].each do |id, data|
      if data.has_key?(:default)
        @current_graph << "#{sep}#{data[:name]} = #{data[:default]}" 
        sep = ", "
      end
    end
    @current_graph << "];\n" if sep == ", "
    
    sep = " "*@indent + "edge["
    @attributs[:edges].each do |id, data|
      if data.has_key?(:default)
        @current_graph << "#{sep}#{data[:name]} = #{data[:default]}" 
        sep == ", "
      end
    end
    @current_graph << "];\n" if sep == ", "
        
    node.each_element( ) do |child|
      send( "graphml_graph_#{child.name}".to_sym, child )
    end
    
    @indent -= 2
    @current_graph << " "*@indent + "}\n"
    @current_graph = previous_graph
  end
  
  def graphml_graph_data( node )
    @current_graph << " "*@indent + "#{@attributs[:graphs][node.attributes['key']][:name]} = #{node.texts()[-1].inspect};\n"
  end
  
  def graphml_graph_node( node )
    @current_node = {}

    node.each_element( ) do |child|
      case child.name
      when "graph"
        graphml_graph( child )
      else
        begin
          send( "graphml_graph_node_#{child.name}".to_sym, child )
        rescue NoMethodError => e
          raise "ERROR node #{child.name} can be child of graphml"
        end
      end
    end
    
    unless @current_node.nil?
      @current_graph << " "*@indent + '"' + node.attributes['id'] + '"'
      sep = "["
      @current_node.each do |k, v|
        # node[k] = v
        if v.class == Array
          @current_graph << "#{sep}#{k} = #{v[-1]}"
        else
          @current_graph << "#{sep}#{k} = #{v.inspect}"
        end
        sep = ", "
      end
      if sep == ", "
        @current_graph << "];\n" 
      else
        @current_graph << "\n"
      end
    end
    
    @current_node = nil
  end
  
  def graphml_graph_node_data( node )
    @current_node[@attributs[:nodes][node.attributes['key']][:name]] = node.texts()
  end
  
  def graphml_graph_node_port( node )
    @current_node[:shape] = "record"
    port = node.attributes['name']
    if @current_node[:label]
      label = @current_node[:label].gsub( "{", "" ).gsub( "}", "" )
      @current_node[:label] = "#{label}|<#{port}> #{port}"
    else
      @current_node[:label] = "<#{port}> #{port}"
    end
  end
  
  def graphml_graph_edge( node )
    source = "\"#{node.attributes['source']}\""
    source = "#{source}:\"#{node.attributes['sourceport']}\"" if node.attributes['sourceport']
    target = "\"#{node.attributes['target']}\""
    target = "#{target}:\"#{node.attributes['targetport']}\"" if node.attributes['targetport']
    
    @current_graph << " "*@indent + "#{source} #{@edge_type} #{target}"

    sep = "["
    node.each_element( ) do |child|
      @current_graph << sep
      send( "graphml_graph_edge_#{child.name}".to_sym, child )
      sep = ", "
    end
    if sep == ", "
      @current_graph << "]\n"
    else
      @current_graph << "\n"
    end
    
    @current_edge = nil
  end

  def graphml_graph_edge_data( node )
    @current_graph << "#{@attributs[:edges][node.attributes['key']][:name]} = #{node.texts()[-1].inspect}"
  end
  
  def graphml_graph_hyperedge( node )
    list = []
    
    node.each_element( ) do |child|
      if child.name == "endpoint"
        if child.attributes['port']
          list << "\"#{child.attributes['node']}\":\"#{child.attributes['port']}\""
        else
          list << '"' + child.attributes['node'] + '"'
        end
      end
    end
    
    list.each { |s|
      list.each { |t|
        # @current_graph.add_edge( s, t ) unless s == t
        @current_graph << " "*@indent + "#{s} #{@edge_type} #{t}\n" unless s == t
      }
    } 
  end
end
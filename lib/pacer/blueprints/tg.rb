module Pacer
  import com.tinkerpop.blueprints.pgm.impls.tg.TinkerGraph
  import com.tinkerpop.blueprints.pgm.impls.tg.TinkerVertex
  import com.tinkerpop.blueprints.pgm.impls.tg.TinkerEdge
  import com.tinkerpop.blueprints.pgm.impls.tg.TinkerElement
  import com.tinkerpop.blueprints.pgm.impls.tg.TinkerIndex

  # Create a new TinkerGraph. If path is given, import the GraphML data from
  # the file specified.
  def self.tg(path = nil)
    graph = TinkerGraph.new
    if path
      graph.import(path)
    end
    graph
  end


  # Extend the java class imported from blueprints.
  class TinkerGraph
    include GraphMixin
    include GraphIndicesMixin
    include GraphTransactionsStub
    include ManagedTransactionsMixin
    include Pacer::Core::Route
    include Pacer::Core::Graph::GraphRoute
    include Pacer::Core::Graph::GraphIndexRoute

    # Override to return an enumeration-friendly array of vertices.
    def get_vertices
      getVertices.iterator.to_route(:graph => self, :element_type => :vertex)
    end

    # Override to return an enumeration-friendly array of edges.
    def get_edges
      getEdges.iterator.to_route(:graph => self, :element_type => :edge)
    end

    def ==(other)
      other.class == self.class and other.object_id == self.object_id
    end

    def element_type(et = nil)
      return nil unless et
      if et == TinkerVertex or et == TinkerEdge or et == TinkerElement
        et
      else
        case et
        when :vertex, com.tinkerpop.blueprints.pgm.Vertex, VertexMixin
          TinkerVertex
        when :edge, com.tinkerpop.blueprints.pgm.Edge, EdgeMixin
          TinkerEdge
        when :mixed, com.tinkerpop.blueprints.pgm.Element, ElementMixin
          TinkerElement
        when :object
          Object
        else
          if et == Object
            Object
          elsif et == TinkerVertex.java_class.to_java
            TinkerVertex
          elsif et == TinkerEdge.java_class.to_java
            TinkerEdge
          else
            raise ArgumentError, 'Element type may be one of :vertex, :edge, :mixed or :object'
          end
        end
      end
    end

    def sanitize_properties(props)
      props
    end

    def encode_property(value)
      if value.is_a? String
        value = value.strip
        value unless value == ''
      else
        value
      end
    end

    def decode_property(value)
      value
    end
  end


  class TinkerIndex
    include IndexMixin
  end


  # Extend the java class imported from blueprints.
  class TinkerVertex
    include Pacer::Core::Graph::VerticesRoute
    include ElementMixin
    include VertexMixin
  end


  # Extend the java class imported from blueprints.
  class TinkerEdge
    include Pacer::Core::Graph::EdgesRoute
    include ElementMixin
    include EdgeMixin

    def in_vertex(extensions = nil)
      v = inVertex
      v.graph = graph
      if extensions.is_a? Enumerable
        v.add_extensions extensions
      elsif extensions
        v.add_extensions [extensions]
      else
        v
      end
    end

    def out_vertex(extensions = nil)
      v = outVertex
      v.graph = graph
      if extensions.is_a? Enumerable
        v.add_extensions extensions
      elsif extensions
        v.add_extensions [extensions]
      else
        v
      end
    end

  end
end

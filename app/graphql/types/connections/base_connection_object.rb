# frozen_string_literal: true

module Types
  module Connections
    # The base connection object type.
    class BaseConnectionObject < GraphQL::Types::Relay::BaseObject
      extend Forwardable
      def_delegators :@object, :cursor_from_node, :parent

      class << self
        # @return [Class]
        attr_reader :node_type

        # @return [Class]
        attr_reader :edge_class

        # Configure this connection to return `edges` and `nodes` based on `edge_type_class`.
        #
        # This method will use the inputs to create:
        # - `edges` field
        # - `nodes` field
        # - description
        #
        # It's called when you subclass this base connection, trying to use the
        # class name to set defaults. You can call it again in the class definition
        # to override the default (or provide a value, if the default lookup failed).
        def edge_type(edge_type_class, edge_class: GraphQL::Relay::Edge,
                      node_type: edge_type_class.node_type, nodes_field: true)
          # Set this connection's graphql name
          node_type_name = node_type.graphql_name

          @node_type = node_type
          @edge_type = edge_type_class
          @edge_class = edge_class

          field :edges, [edge_type_class, { null: true }],
                null: true, description: 'A list of edges.', edge_class: edge_class

          define_nodes_field if nodes_field

          description("The connection type for #{node_type_name}.")
        end

        # Filter this list according to the way its node type would scope them
        delegate :scope_items, to: :node_type

        # Add the shortcut `nodes` field to this connection and its subclasses
        def nodes_field
          define_nodes_field
        end

        def authorized?(_obj, _ctx)
          true # Let nodes be filtered out
        end

        delegate :accessible?, to: :node_type

        delegate :visible?, to: :node_type

        private

        def define_nodes_field
          field :nodes, [@node_type, { null: true }], null: true, description: 'A list of nodes.'
        end
      end

      field :page_info, Types::Relay::PageInfo, null: false,
                                                description: 'Information to aid in pagination.'

      # By default this calls through to the ConnectionWrapper's edge nodes method,
      # but sometimes you need to override it to support the `nodes` field
      def nodes
        @object.edge_nodes
      end

      def edges
        if @object.is_a?(GraphQL::Pagination::Connection)
          @object.edges
        elsif context.interpreter?
          map_edges_from_nodes
        else
          # This is done by edges_instrumentation
          @object.edge_nodes
        end
      end

      private

      def map_edges_from_nodes
        context.schema.after_lazy(object.edge_nodes) do |nodes|
          nodes.map { |n| self.class.edge_class.new(n, object) }
        end
      end
    end
  end
end

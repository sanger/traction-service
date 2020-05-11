# frozen_string_literal: true

module Types
  module Outputs
    # The type for polymorphic Material objects.
    class MaterialUnionType < BaseUnion
      possible_types Types::Outputs::Ont::RequestType, Types::Outputs::Ont::LibraryType

      def self.resolve_type(object, _context)
        if object.is_a?(::Ont::Request)
          Types::Outputs::Ont::RequestType
        elsif object.is_a?(::Ont::Library)
          Types::Outputs::Ont::LibraryType
        else
          raise "Can't determine GraphQL type for: #{object.inspect}"
        end
      end
    end
  end
end

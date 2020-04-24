# frozen_string_literal: true

module Types
  module Outputs
    # The type for polymorphic Material objects.
    class MaterialUnionType < BaseUnion
      possible_types Types::Outputs::Ont::RequestType

      def self.resolve_type(object, _context)
        raise "Can't determine GraphQL type for: #{object.inspect}" unless object.is_a?(::Ont::Request)

        Types::Outputs::Ont::RequestType
      end
    end
  end
end

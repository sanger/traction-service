# frozen_string_literal: true

module Types
  module Outputs
    # The type for polymorphic Material objects.
    class MaterialUnionType < BaseUnion
      possible_types RequestType

      def self.resolve_type(object, context)
        if object.is_a?(Request)
          RequestType
        else
          super.resolve_type(object, context)
        end
      end
    end
  end
end

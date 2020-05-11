# frozen_string_literal: true

module Types
  module Outputs
    module Ont
      # The type for Ont::Request objects.
      class RequestType < CommonOutputObject
        field :name, String, null: false
        field :external_id, String, null: false  
      end
    end
  end
end

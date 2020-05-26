# frozen_string_literal: true

module Types
  module Outputs
    module Ont
      # The type for Ont::Request objects.
      class RequestType < CommonOutputObject
        field :name, String, 'The name of the sample in this request.', null: false
        field :external_id, String, 'The external ID of the sample in this request.', null: false
      end
    end
  end
end

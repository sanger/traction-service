# frozen_string_literal: true

module Types
  module Outputs
    module Ont
      # The type for Ont::Request objects.
      class RequestType < BaseObject
        field :id, ID, null: false
        field :created_at, String, null: false
        field :updated_at, String, null: false

        field :sample, SampleType, null: false
      end
    end
  end
end

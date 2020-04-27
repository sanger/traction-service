# frozen_string_literal: true

module Types
  module Outputs
    module Ont
      # The type for Ont::Request objects.
      class RequestType < CommonOutputObject
        field :sample, SampleType, null: false
      end
    end
  end
end

# frozen_string_literal: true

module Types
  module Inputs
    module Ont
      # The input arguments for a Sample.
      class SampleInputType < BaseInputObject
        argument :name, String, required: false
        argument :external_id, String, required: false
        argument :tag_group_id, String, required: false
      end
    end
  end
end

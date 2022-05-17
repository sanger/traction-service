# frozen_string_literal: true

module Types
  module Inputs
    module Ont
      # The input arguments for a Sample.
      class SampleInputType < BaseInputObject
        argument :name, String, 'The name of the sample.', required: false
        argument :external_id, String, 'The external ID for the sample.', required: false
        argument :tag_oligo, String, 'The oligo sequence used to tag the sample.', required: false
      end
    end
  end
end

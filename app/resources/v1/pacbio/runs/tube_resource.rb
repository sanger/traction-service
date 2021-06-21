# frozen_string_literal: true

module V1
  module Pacbio
    module Runs
      # TubeResource
      class TubeResource < JSONAPI::Resource
        model_name 'Tube'
        attributes :barcode
      end
    end
  end
end

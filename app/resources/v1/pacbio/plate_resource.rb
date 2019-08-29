# frozen_string_literal: true

module V1
  module Pacbio
    # PlateResource
    class PlateResource < JSONAPI::Resource
      model_name 'Pacbio::Plate'

      attributes :pacbio_run_id
    end
  end
end

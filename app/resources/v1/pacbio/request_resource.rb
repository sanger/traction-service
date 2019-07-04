# frozen_string_literal: true

module V1
  module Pacbio
    # RequestResource
    class RequestResource < JSONAPI::Resource
      model_name 'Pacbio::Request'

      attributes :library_type, :estimate_of_gb_required, :number_of_smrt_cells, :cost_code,
                 :external_study_id, :sample_name
    end
  end
end

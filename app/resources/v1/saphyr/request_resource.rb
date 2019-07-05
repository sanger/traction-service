# frozen_string_literal: true

module V1
  module Saphyr
    # RequestResource
    class RequestResource < JSONAPI::Resource
      model_name 'Saphyr::Request'

      attributes :external_study_id, :sample_name
    end
  end
end

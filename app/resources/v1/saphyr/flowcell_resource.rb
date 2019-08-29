# frozen_string_literal: true

module V1
  module Saphyr
    # FlowcellResource
    class FlowcellResource < JSONAPI::Resource
      model_name 'Saphyr::Flowcell'

      attributes :position

      has_one :library, foreign_key_on: :related
    end
  end
end

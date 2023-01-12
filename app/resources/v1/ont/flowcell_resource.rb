# frozen_string_literal: true

module V1
  module Ont
    # FlowcellResource
    class FlowcellResource < JSONAPI::Resource
      model_name 'Ont::Flowcell'

      attributes :flowcell_id, :position, :ont_pool_id

      has_one :pool, foreign_key: 'ont_pool_id', class_name: 'Pool'
    end
  end
end

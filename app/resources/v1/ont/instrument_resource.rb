# frozen_string_literal: true

module V1
  module Ont
    # InstrumentResource
    class InstrumentResource < JSONAPI::Resource
      model_name 'Ont::Instrument'

      attributes :name, :instrument_type, :max_number_of_flowcells
    end
  end
end

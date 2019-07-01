# frozen_string_literal: true

module V1
  module Saphyr
    # EnzymeResource
    class EnzymeResource < JSONAPI::Resource
      model_name 'Saphyr::Enzyme'

      attributes :name
    end
  end
end

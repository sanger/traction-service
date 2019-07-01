# frozen_string_literal: true

module V1
  module Saphyr
    # ChipResource
    class ChipResource < JSONAPI::Resource
      model_name 'Saphyr::Chip'

      attributes :barcode

      has_many :flowcells, foreign_key_on: :related
    end
  end
end

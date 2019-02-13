# frozen_string_literal: true

module V1
  # RunResource
  class RunResource < JSONAPI::Resource
    attributes :state, :chip_barcode

    def chip_barcode
      @model&.chip&.barcode
    end
  end
end

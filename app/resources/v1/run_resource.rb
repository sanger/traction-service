# frozen_string_literal: true

module V1
  # RunResource
  class RunResource < JSONAPI::Resource
    attributes :state, :chip_barcode
    has_one :chip, foreign_key_on: :related

    def chip_barcode
      @model&.chip&.barcode
    end

    # filter :deactivated_at, default: ''
  end
end

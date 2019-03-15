# frozen_string_literal: true

module V1
  # RunResource
  class RunResource < JSONAPI::Resource
    attributes :state, :chip_barcode, :created_at, :name
    has_one :chip, foreign_key_on: :related

    def chip_barcode
      @model&.chip&.barcode
    end

    def created_at
      @model.created_at.strftime('%m/%d/%Y %I:%M')
    end
  end
end

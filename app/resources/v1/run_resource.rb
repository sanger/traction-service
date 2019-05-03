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
      @model.created_at.strftime('%m/%d/%Y %H:%M')
    end

    def self.records(options = {})
      Run.active
    end
  end
end

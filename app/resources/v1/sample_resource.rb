# frozen_string_literal: true

module V1
  # SampleResource
  class SampleResource < JSONAPI::Resource
    attributes :name, :external_id, :species, :barcode, :created_at, :deactivated_at
    has_many :libraries, always_include_linkage_data: true
    has_one :tube

    def barcode
      @model.tube&.barcode
    end

    def created_at
      @model.created_at.strftime('%m/%d/%Y %I:%M')
    end

    def deactivated_at
      @model&.deactivated_at&.strftime('%m/%d/%Y %I:%M')
    end
  end
end

# frozen_string_literal: true

module V1
  # LibraryResource
  class LibraryResource < JSONAPI::Resource
    attributes :state, :barcode, :sample_name
    has_one :sample
    has_one :tube

    def barcode
      @model.tube&.barcode
    end

    def sample_name
      @model.sample&.name
    end
  end
end

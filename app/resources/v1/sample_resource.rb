# frozen_string_literal: true

module V1
  # SampleResource
  class SampleResource < JSONAPI::Resource
    attributes :name, :external_id, :species, :created_at, :deactivated_at

    def created_at
      @model.created_at.strftime('%Y/%m/%d %I:%M')
    end

    def deactivated_at
      @model&.deactivated_at&.strftime('%Y/%m/%d %I:%M')
    end
  end
end

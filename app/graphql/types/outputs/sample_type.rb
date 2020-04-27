# frozen_string_literal: true

module Types
  module Outputs
    # The type for Sample objects.
    class SampleType < CommonOutputObject
      field :name, String, null: false
      field :external_id, String, null: false
      field :species, String, null: false
      field :deactivated_at, String, null: true
    end
  end
end

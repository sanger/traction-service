# frozen_string_literal: true

module Types
  module Outputs
    # The type for Sample objects.
    class SampleType < BaseObject
      field :id, ID, null: false
      field :created_at, String, null: false
      field :updated_at, String, null: false

      field :name, String, null: false
      field :external_id, String, null: false
      field :species, String, null: false
      field :deactivated_at, String, null: true
    end
  end
end

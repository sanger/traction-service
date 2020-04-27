# frozen_string_literal: true

module Types
  module Outputs
    # The object includes fields common to most outputs
    class CommonOutputObject < BaseObject
      field :id, ID, null: false
      field :created_at, String, null: false
      field :updated_at, String, null: false
    end
  end
end

# frozen_string_literal: true

module Types
  module Outputs
    # The object includes fields common to most outputs
    class CommonOutputObject < BaseObject
      field :id, ID, 'The unique database ID of this object.', null: false
      field :created_at, String, 'The time this object was created.', null: false
      field :updated_at, String, 'The time this object was last updated.', null: false
    end
  end
end

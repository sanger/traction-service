# frozen_string_literal: true

# MultiPoolPosition
# An instance of a pool in a MultiPool at a specific position.
class MultiPoolPosition < ApplicationRecord
  belongs_to :pool, polymorphic: true
  belongs_to :multi_pool

  validates :position, presence: true

  # Ensures that each pool can only appear once across multi pools.
  # Disable rubocop rule because it cannot detect the unique index on pool_type and pool_id
  validates :pool_id, uniqueness: { scope: %i[pool_type] }
end

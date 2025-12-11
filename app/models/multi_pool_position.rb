# frozen_string_literal: true

# MultiPoolPosition
# An instance of a pool in a MultiPool at a specific position.
class MultiPoolPosition < ApplicationRecord
  belongs_to :pool, polymorphic: true, inverse_of: :multi_pool_position, optional: true
  belongs_to :multi_pool

  belongs_to :pacbio_pool, class_name: 'Pacbio::Pool', foreign_key: :pool_id, optional: true,
                           inverse_of: :multi_pool_position, dependent: :destroy
  belongs_to :ont_pool, class_name: 'Ont::Pool', foreign_key: :pool_id, optional: true,
                        inverse_of: :multi_pool_position, dependent: :destroy

  validates :position, presence: true

  accepts_nested_attributes_for :pacbio_pool, allow_destroy: true

  # Ensures that each pool can only appear once across multi pools.
  validates :pool_id, uniqueness: { scope: %i[pool_type] }
end

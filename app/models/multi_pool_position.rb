# frozen_string_literal: true

# MultiPoolPosition
# An instance of a pool in a MultiPool at a specific position.
class MultiPoolPosition < ApplicationRecord
  belongs_to :pool, polymorphic: true, inverse_of: :multi_pool_position, optional: true
  belongs_to :multi_pool

  # These should be used sparingly, only for validation and json api nested attributes
  # You may get false positives when fetching if a pool_id matches both tables
  # You should use `pool` polymorphic relationship instead
  belongs_to :pacbio_pool, class_name: 'Pacbio::Pool', foreign_key: :pool_id, optional: true,
                           inverse_of: :multi_pool_position, dependent: :destroy
  belongs_to :ont_pool, class_name: 'Ont::Pool', foreign_key: :pool_id, optional: true,
                        inverse_of: :multi_pool_position, dependent: :destroy

  validates :position, presence: true
  validate :pool_presence

  # Validate that at least one pool is associated
  # We can't validate pool relationship presence because it's polymorphic
  # and may be nil during nested creation within multi_pool_positions
  def pool_presence
    return unless pacbio_pool.nil? && ont_pool.nil?

    errors.add(:pool, 'must have either a pacbio_pool or ont_pool associated')
  end

  accepts_nested_attributes_for :pacbio_pool, allow_destroy: true

  # Ensures that each pool can only appear once across multi pools.
  validates :pool_id, uniqueness: { scope: %i[pool_type] }

  def pipeline
    if pacbio_pool.present?
      :pacbio
    elsif ont_pool.present?
      :ont
    end
  end
end

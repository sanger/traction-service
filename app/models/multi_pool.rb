# frozen_string_literal: true

# MultiPool
# A collection of pools grouped/created together using a specific pooling method.
class MultiPool < ApplicationRecord
  include Pipelineable

  enum :pool_method, { Plate: 0, TubeRack: 1 }

  has_many :multi_pool_positions, dependent: :destroy

  validates :pool_method, presence: true
  validates :pipeline, presence: true
  validates :multi_pool_positions, presence: true
  validate :consistent_pools_type?

  accepts_nested_attributes_for :multi_pool_positions, allow_destroy: true

  # Checks that all pools in the multi pool are of the same type.
  # @return [void]
  def consistent_pools_type?
    return true if multi_pool_positions.empty?

    # pool_type is the polymorphic type of the associated pool e.g. "Ont::Pool" or "Pacbio::Pool"
    return true unless multi_pool_positions.map(&:pool_type).uniq.size > 1

    errors.add(:multi_pool_positions, 'all pools must be of the same type')
    false
  end

  # Checks that all pools in the multi pool have unique positions.
  # @return [void]
  def unique_pool_positions?
    positions = multi_pool_positions.map(&:position)
    duplicate_positions = positions.select { |pos| positions.count(pos) > 1 }

    return true unless duplicate_positions.any?

    errors.add(:multi_pool_positions,
               "#{duplicate_positions.uniq.join(', ')} positions are duplicated")
    false
  end

  # Returns the number of pools in the multi pool.
  # @return [Integer] number of pools
  def number_of_pools
    multi_pool_positions.length
  end
end

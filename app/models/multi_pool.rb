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
  validate :unique_pool_positions?
  validate :sufficient_library_available_volume?, if: -> { pipeline == 'pacbio' }

  accepts_nested_attributes_for :multi_pool_positions, allow_destroy: true

  # Checks that all pools in the multi pool are of the same type.
  # @return [void]
  def consistent_pools_type?
    return true if multi_pool_positions.empty?

    types = multi_pool_positions.map(&:pipeline).compact.uniq

    return true if types.size <= 1

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

  # Extra validation to prevent race conditions where libraries are used across pools in
  # the same multi pool and the total used library volume exceeds the library available volume.
  # This is an edge case because the aliquot volume checks should prevent this from happening
  # but since the pools are created in parallel they are not aware of each others existence
  # so they are not factored into the volume checks.
  def sufficient_library_available_volume? # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength
    used_volume_map = {}
    multi_pool_positions.each do |position|
      next unless position.pacbio_pool

      position.pacbio_pool.used_aliquots.each do |aliquot|
        next unless aliquot.source_type == 'Pacbio::Library'

        used_volume_map[aliquot.source] ||= 0
        used_volume_map[aliquot.source] += aliquot.volume
      end
    end

    used_volume_map.each do |source, used_volume|
      if source.available_volume < used_volume
        errors.add(:base, "#{source.barcode} does not have sufficient available volume")
        return false
      end
    end

    true
  end
end

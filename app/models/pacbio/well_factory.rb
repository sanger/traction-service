# frozen_string_literal: true

# Pacbio namespace
module Pacbio
  # WellFactory
  # A well factory can create multiple wells
  # Each of those wells must have a plate
  # Each well can have multiple pools which must exist
  class WellFactory
    include ActiveModel::Model
    extend NestedValidation

    validates_nested :wells
    validates :wells, presence: { message: 'there are no wells' }

    def initialize(attributes = [])
      build_wells(attributes)
    end

    # A list of WellFactory::Well
    def wells
      @wells ||= []
    end

    def plate
      @plate ||= wells.first.well.plate unless wells.empty?
    end

    def save
      return false unless valid?

      wells.collect(&:save).all?(true)
    end

    private

    def build_wells(wells_attributes)
      wells_attributes.each do |well_attributes|
        wells << Well.new(well_attributes)
      end
    end

    # WellFactory::Well
    class Well
      include ActiveModel::Model
      extend NestedValidation

      validates_nested :well, :pools

      # Pacbio::Well
      attr_reader :well

      def initialize(well_attributes)
        build_well(well_attributes)
      end

      def id
        well.id
      end

      # WellFactory::Well::Pools
      def pools
        @pools ||= []
      end

      def build_well(well_attributes)
        @well = create_or_update_well(well_attributes)
        build_pools(well, well_attributes[:pools])
      end

      def create_or_update_well(well_attributes)
        if well_attributes[:id].present?
          well = Pacbio::Well.find(well_attributes[:id])
          attributes_to_update = well_attributes.except(:id, :pools)
          well.update(attributes_to_update)
        else
          well = Pacbio::Well.new(well_attributes.except(:plate, :pools))
          well.plate = Pacbio::Plate.find_by(id: well_attributes.dig(:plate, :id))
        end
        well
      end

      def build_pools(well, pool_attributes)
        @pools = Pools.new(well, pool_attributes)
      end

      def save
        return false unless valid?

        well.save && pools.save
      end

      # WellFactory::Well::Pools
      class Pools
        include ActiveModel::Model
        attr_reader :well, :pools

        def initialize(well, pool_attributes)
          @well = well
          @pools = find_pools(pool_attributes || [])
        end

        def save
          return false unless valid?

          well.pools = pools
          true
        end

        private

        def find_pools(pool_attributes)
          pool_attributes.filter_map do |pool|
            Pacbio::Pool.find_by(id: pool[:id])
          end
        end
      end
      # keeping here so when we know the previous validations
      # def check_tags_present
      #   return unless all_tags.empty? || all_tags.any?(nil)

      #   errors.add(:tags, 'are missing from the libraries')
      # end

      # def check_tags_uniq
      #   return if all_tags.length == all_tags.uniq.length

      #   errors.add(:tags, "are not unique within the libraries for well #{well.position}")
      # end

      # def check_libraries_max
      #   return if libraries.length <= 16

      #   errors.add(:libraries, "There are more than 16 libraries in well #{well.position}")
      # end
    end
  end
end

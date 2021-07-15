# frozen_string_literal: true

# Pacbio namespace
module Pacbio
  # WellFactory
  # A well factory can create multiple wells
  # Each of those wells must have a plate
  # Each well can have multiple pools which must exist
  class WellFactory
    include ActiveModel::Model

    validate :validate_wells

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

    def validate_wells
      if wells.empty?
        errors.add(:wells, 'there are no wells')
        return
      end

      wells.each do |well|
        next if well.valid?

        well.errors.each do |k, v|
          errors.add(k, v)
        end
      end

      true
    end

    # WellFactory::Well
    class Well
      include ActiveModel::Model

      validate :validate_well

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

        well.save
        return false unless pools.save

        true
      end

      def validate_well
        unless well.valid?
          well.errors.each do |k, v|
            errors.add(k, v)
          end
        end

        return if pools.valid?

        pools.errors.each do |k, v|
          errors.add(k, v)
        end
      end

      # WellFactory::Well::Pools
      class Pools
        include ActiveModel::Model
        attr_reader :well

        def initialize(well, pool_attributes)
          @well = well
          build_pools(pool_attributes)
        end

        # Pacbio::Pool
        def pools
          @pools ||= []
        end

        def save
          return false unless valid?

          destroy_pools
          well.pools << pools
        end

        private

        def build_pools(pool_attributes)
          return if pool_attributes.nil?

          pool_attributes.each do |pool|
            pools << Pacbio::Pool.find(pool[:id]) if Pacbio::Pool.exists?(pool[:id])
          end
        end

        def destroy_pools
          well.pools.destroy_all
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

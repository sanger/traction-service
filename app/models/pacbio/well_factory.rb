# frozen_string_literal: true

# Pacbio namespace
module Pacbio
  # WellFactory
  # A well factory can create multiple wells
  # Each of those wells must have a plate
  # Each well can have multiple libraries which must exist
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

    def factory_errors
      return well_factory_errors unless errors.messages.empty?

      return well_factory_well_errors unless well_factory_well_errors.any?(&:empty?)

      well_factory_well_libraries_errors
    end

    private

    def well_factory_errors
      [errors.messages]
    end

    def well_factory_well_errors
      wells.map(&:errors).collect(&:messages)
    end

    def well_factory_well_libraries_errors
      wells.map(&:libraries).map(&:errors).map(&:messages)
    end

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

      # WellFactory::Well::Libraries
      def libraries
        @libraries ||= []
      end

      def build_well(well_attributes)
        @well = create_or_update_well(well_attributes)
        build_libraries(well, well_attributes[:libraries])
      end

      def create_or_update_well(well_attributes)
        if well_attributes[:id].present?
          well = Pacbio::Well.find(well_attributes[:id])
          attributes_to_update = well_attributes.except(:id, :libraries)
          well.update(attributes_to_update)
        else
          well = Pacbio::Well.new(well_attributes.except(:plate, :libraries))
          well.plate = Pacbio::Plate.find_by(id: well_attributes.dig(:plate, :id))
        end
        well
      end

      def build_libraries(well, libraries_attributes)
        @libraries = Libraries.new(well, libraries_attributes)
      end

      def save
        return false unless valid?

        well.save
        return false unless libraries.save

        true
      end

      def validate_well
        return true if well.valid?

        well.errors.each do |k, v|
          errors.add(k, v)
        end
      end

      # WellFactory::Well::Libraries
      class Libraries
        include ActiveModel::Model
        attr_reader :well

        validate :check_libraries_exist
        validate :check_tags_present, if: :multiple_libraries
        validate :check_tags_uniq, if: :multiple_libraries
        validate :check_libraries_max

        def initialize(well, library_attributes)
          @well = well
          build_libraries(library_attributes)
        end

        # Pacbio::Library
        def libraries
          @libraries ||= []
        end

        def save
          return false unless valid?

          destroy_libraries
          well.libraries << libraries
        end

        private

        def build_libraries(library_attributes)
          return if library_attributes.nil?

          library_attributes.each do |library|
            libraries << Pacbio::Library.find(library[:id]) if Pacbio::Library.exists?(library[:id])
          end
        end

        def destroy_libraries
          well.libraries.destroy_all
        end

        def check_libraries_exist
          return unless libraries.empty?

          errors.add(:libraries, 'do not exist')
        end

        def check_tags_present
          return unless all_tags.empty? || all_tags.any?(nil)

          errors.add(:tags, 'are missing from the libraries')
        end

        def check_tags_uniq
          return if all_tags.length == all_tags.uniq.length

          errors.add(:tags, 'are not unique within the libraries for well ' + well.position)
        end

        def check_libraries_max
          return if libraries.length <= 16

          errors.add(:libraries, 'There are more than 16 libraries in well ' + well.position)
        end

        def multiple_libraries
          libraries.length > 1
        end

        def all_tags
          # This assumes each library has request_libraries
          libraries.collect(&:request_libraries).flatten.collect(&:tag)
        end
      end
    end
  end
end

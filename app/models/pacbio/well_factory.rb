# frozen_string_literal: true

# Pacbio namespace
module Pacbio
  # WellFactory
  # A well factory can create multiple wells
  # Each of those wells must have a plate
  # Each well can have multiple libraries which must exist
  class WellFactory
    include ActiveModel::Model

    validate :check_wells

    def initialize(attributes = [])
      build_wells(attributes)
    end

    def wells
      @wells ||= []
    end

    def save
      return false unless valid?

      wells.collect(&:save)
      true
    end

    def plate
      @plate ||= wells.first.plate unless wells.empty?
    end

    private

    def build_wells(wells_attributes)
      wells_attributes.each do |well_attributes|
        well = create_or_update_well(well_attributes)

        libraries = well_attributes[:libraries]
        build_libraries(well, libraries) unless libraries.nil?

        wells << well
      end
    end

    def build_libraries(well, libraries)
      well_library_factory = WellLibraryFactory.new(well, libraries)
      errors.add(:libraries, well_library_factory.errors.messages) unless well_library_factory.save
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

    def check_wells
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
    end
  end
end

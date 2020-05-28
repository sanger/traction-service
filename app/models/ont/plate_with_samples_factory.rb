# frozen_string_literal: true

# Ont namespace
module Ont
  # PlateWithSamplesFactory
  # A factory for bulk inserting a plate and all of its dependents
  class PlateWithSamplesFactory
    include ActiveModel::Model

    validate :check_plate_factory

    def initialize(attributes = {})
      @attributes = attributes
    end

    def process
      @plate_factory = Ont::PlateFactory.new(attributes)
    end

    def save(**options)
      return false unless options[:validate] == false || valid?

      @serialised_plate_data = plate_factory.bulk_insert_serialise(self, validate: false)
      bulk_insert
    end

    # Serialisation

    def ont_request_data(ont_request, tag_id)
      { ont_request: serialise_ont_request(ont_request), tag_id: tag_id }
    end

    def well_data(well, request_data)
      { well: serialise_well(well), request_data: request_data }
    end

    def plate_data(plate, well_data)
      { plate: serialise_plate(plate), well_data: well_data }
    end

    private

    attr_reader :attributes, :plate_factory, :timestamps, :serialised_plate_data

    def timestamps
      time = DateTime.now
      @timestamps ||= { created_at: time, updated_at: time }
    end

    def serialise_ont_request(ont_request)
      {
        uuid: ont_request.uuid,
        external_id: ont_request.external_id,
        name: ont_request.name
      }.merge(timestamps)
    end

    def serialise_well(well)
      { position: well.position }.merge(timestamps)
    end

    def serialise_plate(plate)
      { barcode: plate.barcode }.merge(timestamps)
    end

    # Saving and Validation

    def check_plate_factory
      return if plate_factory.valid?

      plate_factory.errors.each do |k, v|
        errors.add(k, v)
      end
    end

    def bulk_insert
      # return the plate on success; otherwise false. Unsuccessful inserts should also generate errors
      plate = false
      ActiveRecord::Base.transaction do
        plate = insert_plate
        insert_wells(plate.id)
        # update wells with plate id
        # insert wells
        # other things
      end
      plate
    rescue StandardError => e
      errors.add('import was not successful:', e.message)
      false
    end

    def insert_plate
      plate_data = serialised_plate_data[:plate]
      Plate.insert_all!([plate_data])
      Plate.find_by!(barcode: plate_data[:barcode])
    end

    def insert_wells(plate_id)
      wells_data = serialised_plate_data[:well_data].map do |well_data|
        well_data[:well].merge!({ plate_id: plate_id })
      end
      Well.insert_all!(wells_data)
    end
  end
end

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
      plate = false
      ActiveRecord::Base.transaction do
        plate = insert_plate
        request_uuids = insert_wells_and_ont_requests(plate.id)
        insert_joins(plate.wells, request_uuids)
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

    def insert_wells_and_ont_requests(plate_id)
      requests_data = []
      wells_data = serialised_plate_data[:well_data].map do |well_data|
        requests_data.concat(well_data[:request_data].map { |req_data| req_data[:ont_request] })
        well_data[:well].merge!({ plate_id: plate_id })
      end
      Well.insert_all!(wells_data)
      Ont::Request.insert_all!(requests_data)
      requests_data.map { |req_data| req_data[:uuid] }
    end

    def insert_joins(wells, request_uuids)
      container_materials = []
      tag_taggagbles = []
      requests = Ont::Request.where(uuid: request_uuids).select(:id, :uuid)
      serialised_plate_data[:well_data].each do |well_data|
        well = wells.find { |well| well.position == well_data[:well][:position] }
        well_data[:request_data].each do |request_data|
          request = requests.find { |request| request.uuid == request_data[:ont_request][:uuid] }
          container_materials << container_material(well.id, request.id)
          tag_taggagbles << tag_taggagble(request.id, request_data[:tag_id])
        end
      end
      ContainerMaterial.insert_all!(container_materials)
      TagTaggable.insert_all!(tag_taggagbles)
    end

    def container_material(container_id, material_id)
      {
        container_type: 'Well',
        container_id: container_id,
        material_type: 'Ont::Request',
        material_id: material_id
      }.merge(timestamps)
    end

    def tag_taggagble(taggable_id, tag_id)
      {
        taggable_type: 'Ont::Request',
        taggable_id: taggable_id,
        tag_id: tag_id
      }.merge(timestamps)
    end
  end
end

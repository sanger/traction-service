# frozen_string_literal: true

# Ont namespace
module Ont
  # PlateWithSamplesFactory
  # A factory for bulk inserting a plate and all of its dependents

  # rubocop:disable Metrics/ClassLength
  class PlateWithSamplesFactory
    include ActiveModel::Model

    validate :check_plate_factory

    def initialize(attributes = {})
      @attributes = attributes
      time = DateTime.now
      @timestamps = { created_at: time, updated_at: time }
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
      {
        ont_request: serialise_ont_request(ont_request),
        tag_id: tag_id
      }
    end

    def well_data(well, request_data)
      { well: serialise_well(well), request_data: request_data }
    end

    def plate_data(plate, well_data)
      { plate: serialise_plate(plate), well_data: well_data }
    end

    private

    attr_reader :attributes, :timestamps, :plate_factory, :serialised_plate_data

    def serialise_ont_request(ont_request)
      {
        uuid: SecureRandom.uuid,
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
        request_ids_by_uuid = get_request_ids_by_uuid(request_uuids)
        well_ids_by_position = get_well_ids_by_position(plate.wells)
        insert_joins(well_ids_by_position, request_ids_by_uuid)
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
        well_data[:well].merge({ plate_id: plate_id })
      end
      Well.insert_all!(wells_data)
      Ont::Request.insert_all!(requests_data)
      requests_data.map { |req_data| req_data[:uuid] }
    end

    def get_request_ids_by_uuid(request_uuids)
      Ont::Request.where(uuid: request_uuids).map { |req| [req.uuid, req.id] }.to_h
    end

    def get_well_ids_by_position(wells)
      wells.map { |well| [well.position, well.id] }.to_h
    end

    # rubocop:disable Metrics/AbcSize
    def insert_joins(well_ids_by_position, request_ids_by_uuid)
      container_materials = []
      tag_taggables = []
      serialised_plate_data[:well_data].each do |well_data|
        well_id = well_ids_by_position[well_data[:well][:position]]
        well_data[:request_data].each do |request_data|
          request_id = request_ids_by_uuid[request_data[:ont_request][:uuid]]
          container_materials << container_material(well_id, request_id)
          tag_taggables << tag_taggagble(request_id, request_data[:tag_id])
        end
      end
      ContainerMaterial.insert_all!(container_materials)
      TagTaggable.insert_all!(tag_taggables)
    end
    # rubocop:enable Metrics/AbcSize

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
  # rubocop:enable Metrics/ClassLength
end

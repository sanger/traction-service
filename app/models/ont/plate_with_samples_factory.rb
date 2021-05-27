# frozen_string_literal: true

# Ont namespace
module Ont
  # PlateWithSamplesFactory
  # A factory for bulk inserting a plate and all of its dependents

  # serializations for plate with samples
  module Serializers
    def ont_request_data(ont_request, tag_id)
      {
        ont_request: {
          uuid: SecureRandom.uuid,
          external_id: ont_request.external_id,
          name: ont_request.name
        }.merge(timestamps),
        tag_id: tag_id
      }
    end

    def well_data(well, request_data)
      {
        well: { position: well.position }.merge(timestamps),
        request_data: request_data
      }
    end

    def plate_data(plate, well_data)
      {
        plate: { barcode: plate.barcode }.merge(timestamps),
        well_data: well_data
      }
    end

    def container_material(container_id, material_id)
      {
        container_type: 'Well',
        container_id: container_id,
        material_type: 'Ont::Request',
        material_id: material_id
      }.merge(timestamps)
    end

    def tag_taggable(taggable_id, tag_id)
      {
        taggable_type: 'Ont::Request',
        taggable_id: taggable_id,
        tag_id: tag_id
      }.merge(timestamps)
    end
  end

  # plate with samples factory
  # TODO: the code is linear using things like array first and last
  # and I find it difficult to understand. Add docs and use more OO
  # Thankfully it works well and is encapsulated.
  class PlateWithSamplesFactory
    include ActiveModel::Model
    include Serializers

    validate :check_plate_factory

    #
    # Create a new PlateWithSamplesFactory ready to generate the nested information
    #
    # @param attributes [Hash] Attributes hash
    # @option attributes [String] :barcode The barcode of the plate to generate
    # @option attributes [Array<Hash>] :wells Array of well attributes to use to generate wells
    #
    def initialize(attributes = {})
      @attributes = attributes
    end

    def timestamps
      @timestamps ||= create_timestamps
    end

    def process
      @plate_factory = Ont::PlateFactory.new(attributes)
    end

    def save(**options)
      return false unless options[:validate] == false || valid?

      @serialised_plate_data = plate_factory.bulk_insert_serialise(self, validate: false)
      bulk_insert
    end

    private

    attr_reader :attributes, :plate_factory, :serialised_plate_data

    def create_timestamps
      time = DateTime.now
      { created_at: time, updated_at: time }
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
      parsed_data = serialised_plate_data[:well_data].map do |well_data|
        [
          well_data[:well].merge({ plate_id: plate_id }),
          well_data[:request_data].pluck(:ont_request)
        ]
      end

      wells_data = parsed_data.map(&:first)
      Well.insert_all!(wells_data)

      requests_data = parsed_data.flat_map(&:last)
      Ont::Request.insert_all!(requests_data)

      requests_data.pluck(:uuid)
    end

    def get_request_ids_by_uuid(request_uuids)
      Ont::Request.where(uuid: request_uuids).map { |req| [req.uuid, req.id] }.to_h
    end

    def get_well_ids_by_position(wells)
      wells.map { |well| [well.position, well.id] }.to_h
    end

    def insert_joins(well_ids_by_position, request_ids_by_uuid)
      parsed_data = parsed_plate_data(well_ids_by_position, request_ids_by_uuid)
      ContainerMaterial.insert_all!(parsed_data[:container_materials])
      TagTaggable.insert_all!(parsed_data[:tag_taggables])
    end

    def parsed_plate_data(well_ids_by_position, request_ids_by_uuid)
      serialised_plate_data[:well_data]
        .each_with_object({ container_materials: [], tag_taggables: [] }) do |well_data, result|
        well_id = well_ids_by_position[well_data[:well][:position]]
        parse_well_data(result, well_data, well_id, request_ids_by_uuid)
      end
    end

    def parse_well_data(result, well_data, well_id, request_ids_by_uuid)
      well_data[:request_data].map do |request_data|
        request_id = request_ids_by_uuid[request_data[:ont_request][:uuid]]

        result[:container_materials] << container_material(well_id, request_id)
        result[:tag_taggables] << tag_taggable(request_id, request_data[:tag_id])
      end
    end
  end
end

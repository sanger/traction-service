# frozen_string_literal: true

class Reception
  # Acts on behalf of a {Reception} to construct all associated requests, as well
  # as any necessary samples, plates, wells and tubes.
  # In order to improve performance, the ResourceFactory implements caching of
  # samples and library and data types.
  # This allows up to retrieve all records in a single query upfront, avoiding
  # N+1 query problems. It also ensures we can centralize the registration of
  # new plates and tubes, making it easier to prevent registration of duplicate records.
  class ResourceFactory # rubocop:disable Metrics/ClassLength
    include ActiveModel::Model
    extend NestedValidation
    attr_accessor :reception

    validates :duplicate_containers, absence: true
    validates :requests, presence: true
    validates_nested :requests, :containers, :pool, flatten_keys: false, context: :reception

    def plates_attributes=(plates_attributes)
      create_plates(plates_attributes)
    end

    def tubes_attributes=(tubes_attributes)
      create_tubes(tubes_attributes)
    end

    # new method to handle compound tubes attributes
    def compound_sample_tubes_attributes=(compound_sample_tubes_attributes)
      create_compound_tubes(compound_sample_tubes_attributes)
    end

    def pool_attributes=(pool_attributes)
      create_pool(pool_attributes)
    end

    def pool
      @pool ||= nil
    end

    def libraries
      @libraries ||= []
    end

    def containers
      @containers ||= []
    end

    def requests
      @requests ||= []
    end

    def labware_status
      @labware_status ||= {}
    end

    def construct_resources!
      requests.each(&:save!) # Note this also saves associated records we generate
      labware_status
    end

    # Populates containers and requests from plates_attributes
    def create_plates(plates_attributes)
      plates_attributes.each do |plate_attr|
        # Gets the existing plate or creates a new one
        plate = find_or_create_labware(plate_attr[:barcode], Plate)
        containers << plate
        plate_attr[:wells_attributes].each do |well_attr|
          # Gets the existing well or creates a new one
          well = plate.wells.located_at(well_attr[:position])
          # If a well already exists with records, we want to add an error
          if well.existing_records.present?
            update_labware_status(plate.barcode, 'partial', "#{well.position} already has a sample")
            next
          end

          # Creates a request for the well
          create_request_for_container(well_attr, well)
        end
      end
    end

    # Populates containers and requests from tubes_attributes
    def create_tubes(tubes_attributes)
      tubes_attributes.each do |tube_attr|
        # Gets the existing tube or creates a new one
        tube = find_or_create_labware(tube_attr[:barcode], Tube)
        # If a tube already exists with records, we want to add an error
        if tube.existing_records.present?
          update_labware_status(tube.barcode, 'failed', 'Tube already has a sample')
          next
        end

        # Creates a request for the tube
        create_request_for_container(tube_attr, tube)
      end
    end

    # This method is to
    # 1. create compound sample with component samples
    # 2. create a request for compound sample
    # 3. publish message to warehouse to create compound sample and psd_sample_compounds_components
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/BlockLength
    def create_compound_tubes(compound_tube_attributes)
      # create tubes from compound_tube_attributes
      compound_tube_attributes.each do |tube_attr|
        tube = find_or_create_labware(tube_attr[:barcode], Tube)

        if tube.existing_records.present?
          update_labware_status(tube.barcode, 'failed', 'Tube already has a sample')
          next
        end

        # Retrieve the supplier_name from the first sample in the samples array
        supplier_name = tube_attr[:samples].first[:supplier_name]
        species = tube_attr[:samples].first[:species]

        # Create the compound sample
        compound_sample = create_compound_sample(supplier_name, species)

        # Create the request for the tube using the compound sample
        create_request_for_container(
          {
            sample: compound_sample.attributes.with_indifferent_access,
            request: tube_attr[:request]
          },
          tube
        )

        # Create the compound sample
        compound_sample = create_compound_sample(supplier_name, species)

        # Add component_sample_uuids to the compound_sample object
        compound_sample_with_uuids =
          compound_sample.attributes
                         .slice('id', 'external_id', 'name', 'created_at', 'updated_at')
                         .transform_keys { |key| key == 'external_id' ? 'uuid' : key }
                         .merge(
                           component_sample_uuids: tube_attr[:samples].map do |s|
                             { uuid: s[:external_id] }
                           end
                         )

        # Publish the compound sample to the warehouse
        Messages.publish(compound_sample_with_uuids, Pipelines.reception.compound_sample.message)
      end
    end

    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/BlockLength

    def create_compound_sample(name, species)
      Sample.create!(
        name: name,
        external_id: SecureRandom.uuid,
        species: species
      )
    end

    # Creates a pool from pool_attributes and uses the imported libraries
    def create_pool(pool_attributes)
      return if pool_attributes.blank?

      # Currently only supports Ont
      @pool = Ont::Pool.new(pool_attributes)
      begin
        @pool.libraries = libraries
        update_labware_status(pool_attributes['barcode'], 'success', nil)
      rescue StandardError => e
        update_labware_status(pool_attributes['barcode'], 'failed', e.message)
      end
    end

    def library_type_for(request_attributes)
      # Gets a library type from the cache or returns an unknown type
      library_type = request_attributes[:library_type]
      library_type_cache.fetch(
        library_type,
        UnknownLibraryType.new(library_type:,
                               permitted: library_type_cache.keys)
      )
    end

    def data_type_for(attributes)
      data_type_cache.fetch(attributes[:data_type], nil)
    end

    def sample_for(attributes)
      # Used to reduce database queries.
      # It gets a sample from the cache, if it doesn't exist it searches the database
      # or creates a new one
      sample_cache[attributes[:external_id]] ||=
        Sample.find_by(external_id: attributes[:external_id]) || Sample.new(attributes)
    end

    private

    def find_or_create_labware(barcode, type)
      # Takes a type (Plate or Tube) and searches for an existing record
      # or creates a new one and then populates the labware_status hash
      labware = type.find_by(barcode:) || type.new(barcode:)
      update_labware_status(labware.barcode, 'success', nil)
      labware
    end

    def update_labware_status(barcode, imported, error)
      labware_status[barcode] ||= { imported: 'failed', errors: [] }
      labware_status[barcode][:imported] = imported
      labware_status[barcode][:errors] << error if error
    end

    def create_request_for_container(attributes, container)
      library_type_helper = LibraryTypeHelper.new(library_type_for(attributes[:request]),
                                                  self,
                                                  attributes)
      sample = sample_for(attributes[:sample])
      request = library_type_helper.create_request(sample, container, reception)
      library = library_type_helper.create_library(request)
      libraries << library if library
      requests << request
      containers << container
    end

    def data_type_cache
      # Used to reduce database queries.
      @data_type_cache ||= DataType.all.index_by(&:name)
    end

    def sample_cache
      @sample_cache ||= {}
    end

    def duplicate_containers
      # Groups the containers by class name (Plate, Well, Tube)
      cons = containers.group_by { |container| container.class.name }
      # Checks the wells position/plate are unique and the tubes and plate barcodes are unique
      cons.fetch('Well', []).map { |well| [well.position, well.plate] }.uniq! ||
        cons.fetch('Tube', []).map(&:barcode).uniq! || cons.fetch('Plate', []).map(&:barcode).uniq!
    end

    def library_type_cache
      # Used to reduce database queries.
      @library_type_cache ||= LibraryType.all.index_by(&:name)
    end
  end

  # A helper that deals with the creation of library type specific records.
  class LibraryTypeHelper
    def initialize(library_type, resource_factory, container_attributes)
      @library_type = library_type
      @resource_factory = resource_factory
      @container_attributes = container_attributes
    end

    def create_library(request)
      # The library type is used to help build the correct library in the correct pipeline
      return unless @container_attributes[:library]

      @library_type.library_factory(request:, library_attributes: @container_attributes[:library])
    end

    def create_request(sample, container, reception)
      # The library type is used to help build the correct request in the correct pipeline
      @library_type.request_factory(
        sample:,
        container:,
        request_attributes: @container_attributes[:request],
        resource_factory: @resource_factory,
        reception:
      )
    end
  end
end

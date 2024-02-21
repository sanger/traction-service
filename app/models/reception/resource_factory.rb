# frozen_string_literal: true

class Reception
  # Acts on behalf of a {Reception} to construct all associated requests, as well
  # as any necessary samples, plates, wells and tubes.
  # In order to improve performance, the ResourceFactory implements caching of
  # samples and library and data types.
  # This allows up to retrieve all records in a single query upfront, avoiding
  # N+1 query problems. It also ensures we can centralize the registration of
  # new plates and tubes, making it easier to prevent registration of duplicate records.
  class ResourceFactory
    include ActiveModel::Model
    extend NestedValidation
    attr_accessor :reception

    validates :duplicate_containers, absence: true
    validates :requests, presence: true
    validates_nested :requests, :containers, flatten_keys: false, context: :reception

    def plates_attributes=(plates_attributes)
      create_plates(plates_attributes)
    end

    def tubes_attributes=(tubes_attributes)
      create_tubes(tubes_attributes)
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
      requests.each(&:save!)
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

    def library_type_for(attributes)
      # Gets a library type from the cache or returns an unknown type
      library_type_cache.fetch(attributes[:library_type],
                               UnknownLibraryType.new(library_type: attributes[:library_type],
                                                      permitted: library_type_cache.keys))
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
      library_type = library_type_for(attributes[:request])
      sample = sample_for(attributes[:sample])
      requests << create_request(library_type, sample, container, attributes[:request])
      containers << container
    end

    def create_request(library_type, sample, container, request_attributes)
      # The library type is used to help build the correct request in the correct pipeline
      library_type.request_factory(sample:, container:, request_attributes:,
                                   resource_factory: self, reception:)
    end

    def library_type_cache
      # Used to reduce database queries.
      @library_type_cache ||= LibraryType.all.index_by(&:name)
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
  end
end

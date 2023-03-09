# frozen_string_literal: true

class Reception
  # Acts on behalf of a {Reception} to construct all associated requests, as well
  # as any necessary samples, plates, wells and tubes.
  # In order to improve performance, the ResourceFactory implments caching of
  # associated wells, tubes, plates and samples, as well as library and data
  # types.
  # This allows up to retrieve all records in a single query upfront, avoiding
  # N+1 query problems. It also ensures we can centralize the registration of
  # new plates, making it easier to prevent registration of duplicate records.
  class ResourceFactory
    include ActiveModel::Model
    extend NestedValidation
    attr_accessor :reception

    validates :duplicate_containers, absence: true
    validates :request_attributes, presence: true

    validates_nested :request_attributes, flatten_keys: false

    validates_with ResourceFactoryValidator

    #
    # Array describing the requests to create.
    # Each request consists of:
    #
    # @param attributes [Array<request>] Array containing a hash describing the requests to build
    # @option request [Hash] request: Hash containing the attributes for the request
    # @option request [Hash] sample: Hash containing the attributes for the sample
    # @option request [Hash] container: Hash containing the attributes for the container
    def request_attributes=(attributes)
      @request_attributes = attributes.map do |request_attribute|
        RequestFactory.new(resource_factory: self, reception:, **request_attribute)
      end
    end

    def request_attributes
      @request_attributes ||= []
    end

    def construct_resources!
      ApplicationRecord.transaction do
        # Ensure we correctly populate the cache is we haven't done so already
        request_attributes.each(&:request)
        request_attributes.each(&:save!)
      end
    end

    def sample_for(attributes)
      sample_cache[attributes[:external_id]] ||= Sample.new(attributes)
    end

    #
    # Finds or creates the container with the given attributes
    #
    # @param attributes [Hash] Hash describing the container
    # @option attributes ['tubes','wells'] type: The type of container to create
    # @option attributes [String] barcode: The tube or plate barcode
    # @option attributes [String] position: The well co-ordinate (eg. A1)
    #
    # @return [Tube,Well] The container
    #
    def container_for(attributes)
      case attributes[:type]
      when 'tubes'
        tube_cache[attributes[:barcode]] ||= Tube.new(attributes.slice(:barcode))
      when 'wells'
        plate = plate_cache[attributes[:barcode]] ||= Plate.new(attributes.slice(:barcode))
        plate.wells.located_at(attributes[:position])
      end
    end

    def library_type_for(attributes)
      library_type_cache.fetch(attributes[:library_type]) do
        # If we haven't found a library type, we fall back to a dummy one to
        # handle the validation errors
        UnknownLibraryType.new(
          library_type: attributes[:library_type],
          permitted: library_type_cache.keys
        )
      end
    end

    def data_type_for(attributes)
      data_type_cache.fetch(attributes[:data_type], nil)
    end

    private

    def library_type_cache
      @library_type_cache = LibraryType.all.index_by(&:name)
    end

    def data_type_cache
      @data_type_cache = DataType.all.index_by(&:name)
    end

    def tube_cache
      @tube_cache ||= build_tube_cache
    end

    def plate_cache
      @plate_cache ||= build_plate_cache
    end

    def sample_cache
      @sample_cache ||= build_sample_cache
    end

    def build_tube_cache
      barcodes = request_attributes.filter_map(&:tube_barcode)
      Tube.where(barcode: barcodes).index_by(&:barcode)
    end

    def build_plate_cache
      barcodes = request_attributes.filter_map(&:plate_barcode)
      Plate.where(barcode: barcodes).includes(:wells).index_by(&:barcode)
    end

    def build_sample_cache
      sample_external_ids = request_attributes.filter_map(&:sample_external_id)
      Sample.where(external_id: sample_external_ids).index_by(&:external_id)
    end

    def duplicate_containers
      request_attributes.filter_map(&:container).uniq!
    end
  end
end

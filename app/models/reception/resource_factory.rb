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
    validates :requests, presence: true
    validates_nested :requests, :containers, flatten_keys: false, context: :reception

    def plates_attributes=(plates_attributes)
      @plates_attributes = plates_attributes
      create_plates(plates_attributes)
    end

    def tubes_attributes=(tubes_attributes)
      @tubes_attributes = tubes_attributes
      create_tubes(tubes_attributes)
    end

    def plates_attributes
      @plates_attributes ||= []
    end

    def tubes_attributes
      @tubes_attributes ||= []
    end

    def containers
      @containers ||= []
    end

    def requests
      @requests ||= []
    end

    def reception_errors
      @reception_errors ||= ActiveModel::Errors.new(self)
    end

    def construct_resources!
      requests.each(&:save!)
      reception_errors.full_messages.join(', ')
    end

    def create_plates(plates_attributes)
      plates_attributes.each do |plate_attr|
        plate = find_or_create_plate(plate_attr[:barcode])
        plate_attr[:wells_attributes].each do |well_attr|
          well = plate.wells.located_at(well_attr[:position])
          next if container_has_records(well, "#{plate.barcode}:#{well.position}")

          create_request_for_container(well_attr, well)
          containers << well
        end
        containers << plate
      end
    end

    def create_tubes(tubes_attributes)
      tubes_attributes.each do |tube_attr|
        tube = find_or_create_tube(tube_attr[:barcode])
        next if container_has_records(tube, tube.barcode)

        create_request_for_container(tube_attr, tube)
        containers << tube
      end
    end

    def library_type_for(attributes)
      library_type_cache[attributes[:library_type]] ||=
        LibraryType.find_by(name: attributes[:library_type]) ||
        UnknownLibraryType.new(library_type: attributes[:library_type],
                               permitted: library_type_cache.keys)
    end

    def sample_for(attributes)
      sample_cache[attributes[:external_id]] ||=
        Sample.find_by(external_id: attributes[:external_id]) || Sample.new(attributes)
    end

    private

    def container_has_records(container, barcode)
      return if container.existing_records.blank?

      reception_errors.add(:base, "#{barcode} already has a sample")
      true
    end

    def create_request_for_container(attributes, container)
      lt = library_type_for(attributes[:request])
      sample = sample_for(attributes[:sample])
      requests << create_request(lt, sample, container, attributes[:request])
    end

    def find_or_create_plate(barcode)
      Plate.find_by(barcode:) || Plate.new(barcode:)
    end

    def find_or_create_tube(barcode)
      Tube.find_by(barcode:) || Tube.new(barcode:)
    end

    def create_request(library_type, sample, container, request_attributes)
      library_type.request_factory(
        sample:,
        container:,
        request_attributes:,
        resource_factory: self,
        reception:
      )
    end

    def library_type_cache
      @library_type_cache ||= LibraryType.all.index_by(&:name)
    end

    def sample_cache
      @sample_cache ||= {}
    end

    def duplicate_containers
      plates_attributes.any? do |plate|
        plate[:wells_attributes].flat_map { |well| well[:position] }.uniq!
      end ||
        tubes_attributes.flat_map { |tube| tube[:barcode] }.uniq!
    end
  end
end

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

    validates :requests, presence: true
    validates_nested :requests, flatten_keys: false

    def plates_attributes=(plates_attributes)
      create_plates(plates_attributes)
    end

    def tubes_attributes=(tubes_attributes)
      create_tubes(tubes_attributes)
    end

    def requests
      @requests ||= []
    end

    def reception_errors
      # We use a custom errors object to record non-blocking errors
      @reception_errors ||= ActiveModel::Errors.new(self)
    end

    def construct_resources!
      ApplicationRecord.transaction do
        requests.each(&:save!)
      end

      # Return the errors
      reception_errors.full_messages.join(', ')
    end

    def create_plates(plates_attributes)
      plates_attributes.each do |plate_attr|
        plate = find_or_create_plate(plate_attr[:barcode])

        plate_attr[:wells_attributes].each do |well_attr|
          # Gets existing well or makes empty well
          well = plate.wells.located_at(well_attr[:position])

          if well.existing_records.present?
            reception_errors.add(:base, "#{plate.barcode}:#{well.position} already has a sample")
            next
          end

          create_request_for_container(well_attr, well)
        end
      end
    end

    def create_tubes(tubes_attributes)
      tubes_attributes.each do |tube_attr|
        tube = find_or_create_tube(tube_attr[:barcode])

        if tube.existing_records.present?
          reception_errors.add(:base, "#{tube.barcode} already has a sample")
          next
        end

        create_request_for_container(tube_attr, tube)
      end
    end

    def data_type_for(attributes)
      data_type_cache[attributes[:library_type]] ||=
        DataType.find_by(name: attributes[:data_type]) || nil
    end

    def library_type_for(attributes)
      library_type_cache[attributes[:library_type]] ||=
        LibraryType.find_by(name: attributes[:library_type]) ||
        UnknownLibraryType.new(
          library_type: attributes[:library_type],
          permitted: library_type_cache.keys
        )
    end

    def sample_for(attributes)
      sample_cache[attributes[:external_id]] ||=
        Sample.find_by(external_id: attributes[:external_id]) || Sample.new(attributes)
    end

    private

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

    def data_type_cache
      @data_type_cache ||= DataType.all.index_by(&:name)
    end

    def library_type_cache
      @library_type_cache ||= LibraryType.all.index_by(&:name)
    end

    def sample_cache
      @sample_cache ||= {}
    end
  end
end

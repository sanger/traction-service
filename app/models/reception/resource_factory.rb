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
    attr_accessor :reception

    attr_writer :plates_attributes, :tubes_attributes

    def plates_attributes
      @plates_attributes ||= []
    end

    def tubes_attributes
      @tubes_attributes ||= []
    end

    def reception_errors
      # We use a custom errors object to record non-blocking errors
      @reception_errors ||= ActiveModel::Errors.new(self)
    end

    def construct_resources!
      # Create the resources
      create_plates
      create_tubes

      # Return the errors
      reception_errors.full_messages.join(', ')
    end

    def create_plates
      @plates_attributes.each do |plate_attr|
        plate = find_or_create_plate(plate_attr[:barcode])

        plate_attr[:wells_attributes].each do |well_attr|
          # Gets existing well or makes empty well
          well = plate.wells.located_at(well_attr[:position])

          if well.existing_records.present?
            reception_errors.add(:base, "#{plate.barcode}:#{well.position} already has a sample")
            next
          end

          create_request_for_container(well_attr[:request], well,
                                       "#{plate.barcode}:#{well.position}")
        end
      end
    end

    def create_tubes
      @tubes_attributes.each do |tube_attr|
        tube = find_or_create_tube(tube_attr[:barcode])

        if tube.existing_records.present?
          reception_errors.add(:base, "#{tube.barcode} already has a sample")
          next
        end

        create_request_for_container(tube_attr[:request], tube, tube.barcode)
      end
    end

    private

    def create_request_for_container(request_attributes, container, container_barcode)
      lt = library_type_cache.fetch(request_attributes[:library_type], nil)
      if lt.nil?
        reception_errors.add(
          :base, "#{container_barcode} Library type #{request_attributes[:library_type]} not found"
        )
        return
      end

      sample = sample_for(request_attributes[:sample])
      request = create_request(lt, sample, container, request_attributes)
      request.save!
    end

    def sample_for(attributes)
      sample_cache[attributes[:external_id]] ||=
        Sample.find_by(external_id: attributes[:external_id]) || Sample.new(attributes)
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
        library_type:,
        request_attributes:,
        reception:
      )
    end

    def library_type_cache
      @library_type_cache ||= LibraryType.all.index_by(&:name)
    end

    def sample_cache
      @sample_cache ||= {}
    end
  end
end

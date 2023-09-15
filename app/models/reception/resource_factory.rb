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

        # Attempt to create each well in the plate
        plate_attr[:wells_attributes].each do |well_attr|
          # Gets existing well or makes empty well
          well = plate.wells.located_at(well_attr[:position])
          # If well has existing records, skip and add error
          if well.existing_records.present?
            reception_errors.add(:base, "#{plate.barcode}:#{well.position} already has a sample")
            next
          end

          # Use the library type to identify the pipeline
          lt = library_type_cache.fetch(well_attr[:request][:library_type], nil)
          # Raise missing library type error
          if lt.nil?
            reception_errors.add(
              :base, "#{plate.barcode}:#{well.position} Library type #{well_attr[:request][:library_type]} not found"
            )
            next
          end

          # Get existing sample or make new sample
          sample = sample_for(well_attr[:sample])

          # Using the library type, create a request
          request = create_request(lt, sample, well, well_attr[:request])

          # Save the request which also saves related records (sample, well, plate)
          request.save!
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

        # Use the library type to identify the pipeline
        lt = library_type_cache.fetch(tube_attr[:request][:library_type], nil)
        # Raise missing library type error
        if lt.nil?
          reception_errors.add(
            :base, "#{tube.barcode} Library type #{tube_attr[:request][:library_type]} not found"
          )
          next
        end

        # Get existing sample or make new sample
        sample = sample_for(tube_attr[:sample])

        # Using the library type, create a request
        request = create_request(lt, sample, tube, tube_attr[:request])

        # Save the request which also saves related records (sample, tube)
        request.save!
      end
    end

    private

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

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

    validates_nested :plates_attributes, flatten_keys: false
    validates_nested :tubes_attributes, flatten_keys: false

    def plates_attributes=(attributes)
      @plates_attributes = attributes
    end

    def tubes_attributes=(attributes)
      @tubes_attributes = attributes
    end

    def plates_attributes
      @tubes_attributes ||= []
    end

    def tubes_attributes
      @tubes_attributes ||= []
    end

    def construct_resources!
      create_plates
      create_tubes
    end

    def create_plates
      @plates_attributes.each do |plate_attr|
        # Get existing plate or make new plate
        plate = Plate.find_by(barcode: plate_attr[:barcode]) || Plate.new(plate_attr.slice(:barcode))
  
        # Attempt to create each well in the plate
        plate_attr[:wells_attributes].each do |well_attr|
          # Gets existing well or makes empty well
          well = plate.wells.located_at(well_attr[:position])
          # If well has existing records, skip and add errror
          if well.existing_records.present?
            self.errors.add(:base, "#{well.position} already has a sample")
          end
  

          # Use the library type to identify the pipeline
          # If library type is not found, skip
          # TODO: We want to add an error saying library type is not found for well
          lt = library_type_for(well_attr[:request])
          next if lt.nil?

          # Get existing sample or make new sample
          sample = sample_for(well_attr[:sample])
  
          # Using the library type, create a request
          request = lt.request_factory(
            sample: sample,
            container: well,
            library_type: lt,
            request_attributes: well_attr[:request],
            reception:
          )
  
          # Save the request which also saves related records (sample, well, plate etc)
          request.save!
        end
      end
    end

    def create_tubes
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

    def sample_for(attributes)
      sample_cache[attributes[:external_id]] ||= Sample.find_by(external_id: attributes[:external_id]) || Sample.new(attributes)
    end

    private

    def library_type_cache
      @library_type_cache = LibraryType.all.index_by(&:name)
    end

    def sample_cache
      @sample_cache ||= {}
    end

  end
end

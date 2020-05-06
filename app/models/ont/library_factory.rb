# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength

# Ont namespace
module Ont
  # LibraryFactory
  # The factory will create libraries in tubes from a given plate
  class LibraryFactory
    include ActiveModel::Model

    validate :check_validation_errors, :check_libraries, :check_library_requests, :check_container_materials

    def initialize(attributes = {})
      @validation_errors = []
      @libraries = []
      @library_requests = []
      @tubes = []
      @container_materials = []

      return unless fetch_and_validate_entities(attributes)

      num_libraries.times do |lib_idx|
        build_library(lib_idx, @tag_set.tags.count)
      end
    end

    attr_reader :tubes

    def save
      return false unless valid?

      @libraries.each { |lib| lib.save(validate: false) }
      @library_requests.each { |lib_req| lib_req.save(validate: false) }
      @tubes.each { |tube| tube.save(validate: false) }
      @container_materials.each { |cont_mat| cont_mat.save(validate: false) }
      true
    end

    private

    attr_reader :validation_errors,
                :tag_set,
                :plate,
                :num_libraries,
                :sorted_wells,
                :library_requests,
                :container_materials

    def fetch_and_validate_entities(attributes)
      try_get_tag_set(attributes[:tag_set_name]) &&
        try_get_plate(attributes[:plate_barcode]) &&
        validate_tag_set_for_plate &&
        try_get_sorted_wells(attributes[:well_primary_grouping_direction])
    end

    def try_get_tag_set(tag_set_name)
      @tag_set = ::TagSet.find_by(name: tag_set_name)
      return true unless @tag_set.nil?

      validation_errors << ['Tag set', 'must exist']
      false
    end

    def try_get_plate(plate_barcode)
      @plate = ::Plate.find_by(barcode: plate_barcode)
      return true unless @plate.nil?

      validation_errors << ['Plate', 'must exist']
      false
    end

    def validate_tag_set_for_plate
      num_wells = @plate.wells.count
      num_tags = @tag_set.tags.count
      if num_wells == 0 && num_tags == 0
        @num_libraries = 0
        return true
      elsif num_tags != 0 && num_wells % num_tags == 0
        @num_libraries = num_wells / num_tags
        return true
      end

      validation_errors << ['Tag set', 'tag count must be a factor of plate well count']
      false
    end

    def try_get_sorted_wells(primary_grouping_direction)
      if primary_grouping_direction == 'vertical'
        @sorted_wells = @plate.wells_by_column_then_row
        true
      elsif primary_grouping_direction == 'horizontal'
        @sorted_wells = @plate.wells_by_row_then_column
        true
      else
        validation_errors << ['Wells',
                              "cannot be grouped by direction '#{primary_grouping_direction}'"]
        false
      end
    end

    def build_library(lib_idx, num_tags)
      pool = lib_idx + 1
      name = Ont::Library.library_name(@plate.barcode, pool)
      @libraries << Ont::Library.new(name: name, pool: pool, pool_size: num_tags)
      build_library_requests(@sorted_wells[(lib_idx * num_tags), num_tags], @libraries.last)
      add_to_tube(@libraries.last)
    end

    def build_library_requests(wells, library)
      @tag_set.tags.each_with_index do |tag, tag_idx|
        wells[tag_idx].materials.each do |request|
          @library_requests << Ont::LibraryRequest.new(library: library, request: request, tag: tag)
        end
      end
    end

    def add_to_tube(library)
      @tubes << Tube.new
      @container_materials << ::ContainerMaterial.new(container: @tubes.last,
                                                      material: library)
    end

    def check_validation_errors
      return if @validation_errors.empty?

      validation_errors.each do |validation_error|
        errors.add(validation_error[0], validation_error[1])
      end
    end

    def check_libraries
      if @libraries.empty?
        errors.add('libraries', 'were not created')
        return
      end

      @libraries.each do |library|
        next if library.valid?

        library.errors.each do |k, v|
          errors.add(k, v)
        end
      end
    end

    def check_library_requests
      @library_requests.each do |library_request|
        next if library_request.valid?

        library_request.errors.each do |k, v|
          errors.add(k, v)
        end
      end
    end

    def check_container_materials
      @container_materials.each do |container_material|
        next if container_material.valid?

        container_material.errors.each do |k, v|
          errors.add(k, v)
        end
      end
    end
  end
end

# rubocop:enable Metrics/ClassLength

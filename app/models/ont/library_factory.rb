# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength

# Ont namespace
module Ont
  # LibraryFactory
  # The factory will create libraries from a given plate
  class LibraryFactory
    include ActiveModel::Model

    validate :check_validation_errors, :check_libraries, :check_tag_taggables

    def initialize(attributes = {})
      @validation_errors = []
      @libraries = []
      @tag_taggables = []
      @container_materials = []

      return unless fetch_and_validate_entities(attributes)

      num_libraries.times do |lib_idx|
        build_library(lib_idx, @tag_set.tags.count)
      end
    end

    def save
      return false unless valid?

      @libraries.collect(&:save)
      @tag_taggables.collect(&:save)
      @container_materials.collect(&:save)
      true
    end

    private

    attr_reader :validation_errors,
                :tag_set,
                :plate,
                :num_libraries,
                :sorted_wells,
                :tag_taggables,
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
      wells = get_wells(lib_idx, num_tags)
      pool = lib_idx + 1
      @libraries << Library.new(name: "#{@plate.barcode}-#{pool}",
                                well_range: "#{wells[0].position}-#{wells[-1].position}",
                                pool: pool,
                                pool_size: num_tags,
                                requests: get_and_tag_requests(wells))
      @container_materials << ::ContainerMaterial.new(container: Tube.new,
                                                      material: @libraries.last)
    end

    def get_wells(lib_idx, num_tags)
      @sorted_wells[(lib_idx * num_tags), num_tags]
    end

    def get_and_tag_requests(wells)
      all_requests = []
      @tag_set.tags.each_with_index do |tag, tag_idx|
        wells[tag_idx].materials.each do |request|
          @tag_taggables << ::TagTaggable.new(taggable: request, tag: tag)
          all_requests << request
        end
      end
      all_requests
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

    def check_tag_taggables
      @tag_taggables.each do |tag_taggable|
        next if tag_taggable.valid?

        tag_taggable.errors.each do |k, v|
          errors.add(k, v)
        end
      end
    end
  end
end

# rubocop:enable Metrics/ClassLength

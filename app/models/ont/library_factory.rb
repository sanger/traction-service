# frozen_string_literal: true

# Ont namespace
module Ont
  # LibraryFactory
  # The factory will create libraries in tubes from a given plate
  class LibraryFactory
    include ActiveModel::Model

    validate :check_library,
             :check_tube,
             :check_container_material

    def initialize(attributes = {})
      build_library(attributes)
    end

    attr_reader :tube

    def save(**options)
      return false unless options[:validate] == false || valid?

      library.save(validate: false)
      tube.save(validate: false)
      container_material.save(validate: false)
      true
    end

    private

    attr_reader :library, :container_material

    def build_library(attributes)
      plate = ::Plate.find_by(barcode: attributes[:plate_barcode])
      return if plate.nil?

      requests = plate.wells.flat_map(&:materials)
      return unless check_requests_uniquely_tagged(requests)

      @library = Ont::Library.new(name: Ont::Library.library_name(plate.barcode, 1),
                                  pool: 1,
                                  pool_size: plate.wells.count,
                                  requests: requests)
      add_to_tube(library)
    end

    def check_requests_uniquely_tagged(requests)
      unique_oligo_joins = Set.new
      requests.each do |request|
        unique_oligo_joins.add(request.sorted_tags.map(&:oligo).join)
      end
      unique_oligo_joins.count == requests.count
    end

    def add_to_tube(library)
      @tube = Tube.new
      @container_material = ::ContainerMaterial.new(container: tube, material: library)
    end

    def check_library
      if library.nil?
        errors.add('library', 'was not created')
        return
      end

      return if library.valid?

      library.errors.each do |k, v|
        errors.add(k, v)
      end
    end

    def check_tube
      if tube.nil?
        errors.add('tube', 'was not created')
        return
      end

      return if tube.valid?

      tube.errors.each do |k, v|
        errors.add(k, v)
      end
    end

    def check_container_material
      if container_material.nil?
        errors.add('container material', 'was not created')
        return
      end

      return if container_material.valid?

      container_material.errors.each do |k, v|
        errors.add(k, v)
      end
    end
  end
end

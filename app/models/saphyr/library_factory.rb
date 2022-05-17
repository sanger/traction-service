# frozen_string_literal: true

# Saphyr namespace
module Saphyr
  # LibraryFactory
  # A library factory can create multiple libraries
  # Each of those libraries is a material with a tube
  class LibraryFactory
    include ActiveModel::Model

    validate :check_libraries

    def initialize(attributes = [])
      attributes.each do |library|
        libraries << Saphyr::Library.new(library)
        container_materials << ContainerMaterial.new(container: Tube.new, material: libraries.last)
      end
    end

    def libraries
      @libraries ||= []
    end

    def container_materials
      @container_materials ||= []
    end

    def save
      return false unless valid?

      libraries.collect(&:save)
      container_materials.collect(&:save)
      true
    end

    private

    def check_libraries
      if libraries.empty?
        errors.add('libraries', 'the were no libraries')
        return
      end

      libraries.each do |library|
        next if library.valid?

        library.errors.each do |error|
          errors.add(error.attribute, error.message)
        end
      end
    end
  end
end

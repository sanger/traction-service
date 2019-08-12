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
      attributes.each { |library| libraries << Saphyr::Library.new(library.merge!(tube: Tube.new)) }
    end

    def libraries
      @libraries ||= []
    end

    def save
      return false unless valid?

      libraries.collect(&:save)
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

        library.errors.each do |k, v|
          errors.add(k, v)
        end
      end
    end
  end
end

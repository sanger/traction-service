# frozen_string_literal: true

module Pacbio
  # Pacbio::WellLibrary
  # Creates associations between wells and libraries
  # Checks whether the tags in the wells are unique
  class WellLibraryFactory
    include ActiveModel::Model

    attr_reader :well

    validate :check_tags_present, if: :multiple_libraries
    validate :check_tags_uniq, if: :multiple_libraries
    validate :check_libraries_max

    def initialize(well, library_attributes)
      @well = well
      build_libraries(library_attributes)
    end

    def libraries
      @libraries ||= []
    end

    def save
      return unless valid?

      destroy_libraries
      well.libraries << libraries
      true
    end

    private

    def build_libraries(library_attributes)
      library_attributes.each do |library|
        libraries << Pacbio::Library.find(library[:id]) if Pacbio::Library.exists?(library[:id])
      end
    end

    def destroy_libraries
      well.libraries.destroy_all
    end

    def check_tags_uniq
      return if all_tags.length == all_tags.uniq.length

      errors.add(:tags, 'are not unique within the libraries for well ' + well.position)
    end

    def check_tags_present
      return unless all_tags.any?(nil)

      errors.add(:tags, 'are missing from the libraries')
    end

    def check_libraries_max
      return if libraries.length <= 16

      errors.add(:libraries, 'There are more than 16 libraries in well ' + well.position)
    end

    def multiple_libraries
      libraries.length > 1
    end

    def all_tags
      # This assumes each library has request_libraries
      libraries.collect(&:request_libraries).flatten.collect(&:tag)
    end
  end
end

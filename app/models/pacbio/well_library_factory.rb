# frozen_string_literal: true

module Pacbio
  # Pacbio::WellLibrary
  # Creates associations between wells and libraries
  # Checks whether the tags in the wells are unique
  class WellLibraryFactory
    include ActiveModel::Model

    attr_reader :well

    validate :check_tags

    def initialize(well, library_attributes)
      @well = well
      build_libraries(library_attributes)
    end

    def libraries
      @libraries ||= []
    end

    def save
      return unless valid?

      well.libraries << libraries
      true
    end

    private

    def build_libraries(library_attributes)
      library_attributes.each do |library|
        libraries << Pacbio::Library.find(library[:id])
      end
    end

    def check_tags
      all_tags = well.tags + libraries.collect(&:request_libraries).flatten.collect(&:tag_id)
      return if all_tags.length == all_tags.uniq.length

      errors.add(:tags, 'are not unique within the libraries')
    end
  end
end

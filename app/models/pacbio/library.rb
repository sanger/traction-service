# frozen_string_literal: true

module Pacbio
  # Pacbio::Library
  # A Pacbio Library is capable of being multiplexed i.e.
  # is capable of containing several samples in the form of requests.
  # A library can have many requests but can also belong to many requests
  # A library can be sequenced in more than one well.
  # This is achieved using a has many through relationship
  class Library < ApplicationRecord
    include TubeMaterial
    include Uuidable
    include Librarian

    validates :volume, :concentration, :template_prep_kit_box_barcode,
              :fragment_size, presence: true

    has_many :well_libraries, class_name: 'Pacbio::WellLibrary', foreign_key: :pacbio_library_id,
                              dependent: :nullify, inverse_of: :library
    has_many :wells, class_name: 'Pacbio::Well', through: :well_libraries
    has_many :request_libraries, class_name: 'Pacbio::RequestLibrary',
                                 foreign_key: :pacbio_library_id, dependent: :destroy,
                                 inverse_of: :library, autosave: true

    has_many :requests, class_name: 'Pacbio::Request', through: :request_libraries

    delegate :barcode, to: :tube

    def sample_names
      return '' if requests.blank?

      requests.collect(&:sample_name).join(',')
    end

    # Identifies the plate and wells from which the library was created
    # Typically in the format: DN123:A1-D1
    # @note Assumes 96 well plates. formatted_range can take a second argument
    # of plate_size if this ever changes.
    def source_identifier
      wells_grouped_by_container.map do |plate_barcode, well_positions|
        well_range = WellSorterService.formatted_range(well_positions)
        "#{plate_barcode}:#{well_range}"
      end.join(',')
    end

    private

    def wells_grouped_by_container
      requests.each_with_object({}) do |request, store|
        store[request.container.plate.barcode] ||= []
        store[request.container.plate.barcode] << request.container.position
      end
    end
  end
end

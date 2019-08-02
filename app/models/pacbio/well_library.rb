# frozen_string_literal: true

module Pacbio
  # Pacbio::WellLibrary
  class WellLibrary < ApplicationRecord
    belongs_to :well, class_name: 'Pacbio::Well', foreign_key: :pacbio_well_id,
                      inverse_of: :well_libraries
    belongs_to :library, class_name: 'Pacbio::Library', foreign_key: :pacbio_library_id,
                         inverse_of: :well_libraries
  end
end

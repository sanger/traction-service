# frozen_string_literal: true

module Pacbio
  # Pacbio::Library
  class Library < ApplicationRecord
    validates :volume, :concentration, :library_kit_barcode, :fragment_size, presence: true

    belongs_to :tag, class_name: 'Pacbio::Tag', foreign_key: :pacbio_tag_id,
                     optional: false, inverse_of: false
    belongs_to :well, class_name: 'Pacbio::Well', foreign_key: :pacbio_well_id,
                      inverse_of: :library, optional: true

    belongs_to :sample
  end
end

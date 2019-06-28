# frozen_string_literal: true

# Saphyr namespace
module Saphyr
  # Flowcell
  class Flowcell < ApplicationRecord
    belongs_to :library, foreign_key: 'saphyr_library_id', optional: true
    belongs_to :chip, class_name: 'Saphyr::Chip', foreign_key: 'saphyr_chip_id', inverse_of: :flowcells, dependent: :destroy

    validates :position, presence: true
  end
end

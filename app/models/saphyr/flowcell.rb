# frozen_string_literal: true

# Saphyr namespace
module Saphyr
  # Flowcell
  class Flowcell < ApplicationRecord
    belongs_to :library, optional: true
    validates :position, presence: true
    belongs_to :chip, class_name: 'Saphyr::Chip', foreign_key: 'saphyr_chip_id', dependent: :destroy
  end
end

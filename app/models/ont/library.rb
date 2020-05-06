# frozen_string_literal: true

module Ont
  # Ont::Library
  class Library < ApplicationRecord
    include Material

    # has_many :requests, foreign_key: :ont_library_id, inverse_of: :library, dependent: :destroy

    validates :name, :plate_barcode, :pool, :well_range, :pool_size, presence: true

    # Dynamically calculated/transient attributes:
    # - tag_set_name
    # - tube_barcode
  end
end

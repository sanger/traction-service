# frozen_string_literal: true

module Ont
  # Ont::Library
  class Library < ApplicationRecord
    include Material

    has_many :requests, inverse_of: :library, dependent: :destroy

    validates :plate_barcode, :pool, :well_range, :pool_size, presence: true

    def name
      "#{plate_barcode}-#{pool}"
    end
  end
end

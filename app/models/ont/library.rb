# frozen_string_literal: true

module Ont
  # Ont::Library
  class Library < ApplicationRecord
    include Material

    has_many :library_requests, foreign_key: :ont_library_id,
                                inverse_of: :library, dependent: :destroy

    validates :name, :plate_barcode, :pool, :well_range, :pool_size, presence: true

    # Dynamically calculated/transient attributes:
    # - tag_set_name
    # - tube_barcode

    def tag_set_name
      library_requests.first.nil? ? nil : library_requests.first.tag.tag_set_name
    end

    def tube_barcode
      return nil if container_material.nil? || !container_material.container.is_a?(::Tube)

      container_material.container.barcode
    end
  end
end

# frozen_string_literal: true

module Ont
  # Ont::Library
  class Library < ApplicationRecord
    include Material
    include Uuidable
    include Librarian

    validates :volume, :concentration,
              :insert_size, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

    belongs_to :request, class_name: 'Ont::Request', foreign_key: :ont_request_id,
                         inverse_of: :libraries
    belongs_to :tag, optional: true
    belongs_to :pool, class_name: 'Ont::Pool', foreign_key: :ont_pool_id,
                      inverse_of: :libraries

    include DualSourcedLibrary

    has_one :sample, through: :request
    has_one :tube, through: :pool
    has_one :tag_set, through: :tag
    has_one :source_plate, through: :source_well, source: :plate, class_name: '::Plate'

    def collection?
      false
    end

    # The tag.group_id 'Barcode' used for sample sheet generation
    def tag_barcode
      tag&.group_id
    end
  end
end

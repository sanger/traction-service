# frozen_string_literal: true

module Pacbio
  # Plate
  class Plate < ApplicationRecord
    include Uuidable

    belongs_to :run, foreign_key: :pacbio_run_id,
                     inverse_of: :plates
    has_many :wells, class_name: 'Pacbio::Well', foreign_key: :pacbio_plate_id,
                     inverse_of: :plate, dependent: :destroy, autosave: true

    accepts_nested_attributes_for :wells, allow_destroy: true

    # we maybe still need this in case someone tries to create a
    # non sequel IIe or Revio run
    validates :sequencing_kit_box_barcode, :plate_number, presence: true
  end
end

# frozen_string_literal: true

module Pacbio
  # Plate
  class Plate < ApplicationRecord
    include Uuidable

    belongs_to :run, foreign_key: :pacbio_run_id,
                     inverse_of: :plate
    has_many :wells, class_name: 'Pacbio::Well', foreign_key: :pacbio_plate_id,
                     inverse_of: :plate, dependent: :destroy

    def all_wells_have_pools?
      return false if wells.empty?

      wells.all?(&:pools?)
    end
  end
end

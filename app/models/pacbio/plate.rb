# frozen_string_literal: true

module Pacbio
  # Plate
  class Plate < ApplicationRecord
    belongs_to :run, class_name: 'Pacbio::Run', foreign_key: :pacbio_run_id,
                     inverse_of: :plate

    has_many :wells, class_name: 'Pacbio::Well', foreign_key: :pacbio_run_id,
                     inverse_of: :plate, dependent: :destroy
  end
end

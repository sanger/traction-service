module Pacbio
  class Plate < ApplicationRecord

    belongs_to :run, class_name: 'Pacbio::Run', foreign_key: :pacbio_run_id
  end
end
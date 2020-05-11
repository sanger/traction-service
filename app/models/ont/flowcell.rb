# frozen_string_literal: true

module Ont
  # Ont::Flowcell
  class Flowcell < ApplicationRecord
    include Uuidable

    belongs_to :run, foreign_key: :ont_run_id, inverse_of: :flowcells, dependent: :destroy
    belongs_to :library, foreign_key: :ont_library_id, inverse_of: :flowcell

    validates :position,
              presence: true,
              uniqueness: { scope: :ont_run_id,
                            message: 'position should only appear once within run' }
  end
end

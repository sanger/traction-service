# frozen_string_literal: true

module Ont
  # Ont::Flowcell
  class Flowcell < ApplicationRecord
    include Uuidable

    belongs_to :run, foreign_key: :ont_run_id, inverse_of: :flowcells, dependent: :destroy
    has_one :library, foreign_key: :ont_flowcell_id, inverse_of: :flowcell, dependent: :nullify

    validates :position, :library, presence: true
  end
end

# frozen_string_literal: true

module Ont
  # Ont::Flowcell
  class Flowcell < ApplicationRecord
    include Uuidable

    # Run has many of these flowcells up to the maximum number for the instrument.
    belongs_to :run, foreign_key: :ont_run_id, inverse_of: :flowcells

    # We assume one-to-one relationship with pool at the moment.
    belongs_to :pool, foreign_key: :ont_pool_id, inverse_of: :flowcell

    delegate :requests, to: :pool

    # Validate the position to be a positive integer.
    validates :position,
              presence: true,
              numericality: { greater_than_or_equal_to: 1 }
    validates :flowcell_id, presence: true
  end
end

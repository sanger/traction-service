# frozen_string_literal: true

module Ont
  # Ont::Flowcell
  class Flowcell < ApplicationRecord
    include Uuidable

    # Run has multiple of these flowcells up to the maximum number for the instrument.
    belongs_to :run, foreign_key: :ont_run_id, inverse_of: :flowcells

    # We have changed the model to use pool rather than library.
    # We assume one-to-one relationship with pool at the moment.
    # belongs_to :library, foreign_key: :ont_library_id, inverse_of: :flowcell
    belongs_to :pool, foreign_key: :ont_pool_id, inverse_of: :flowcell

    # We have changed the delegation to expose public methods of pool rather than library.
    # XXX: How/where are we associating requests?
    # delegate :requests, to: :library
    delegate :requests, :libraries, to: :pool

    # Validate uniqueness of the position of flowcell among others of the same run.
    # Validate the position to be a positive integer.
    validates :position,
              presence: true,
              uniqueness: { scope: :ont_run_id,
                            message: :duplicated_in_run },
              numericality: { greater_than_or_equal_to: 1 }
    validates :flowcell_id, presence: true
  end
end

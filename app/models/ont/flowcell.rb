# frozen_string_literal: true

module Ont
  # Ont::Flowcell
  class Flowcell < ApplicationRecord
    # Currently redundant, will need to be re-implemented soon
    include Uuidable

    belongs_to :run, foreign_key: :ont_run_id, inverse_of: :flowcells
    belongs_to :library, foreign_key: :ont_library_id, inverse_of: :flowcell
    delegate :requests, to: :library

    validates :position,
              presence: true,
              uniqueness: { scope: :ont_run_id,
                            message: :duplicated_in_run }

    # Make table read only. We don't want anything pushing to it.
    def readonly?
      true
    end
  end
end

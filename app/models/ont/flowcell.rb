# frozen_string_literal: true

module Ont
  # Ont::Flowcell
  class Flowcell < ApplicationRecord
    include Uuidable

    belongs_to :run, foreign_key: :ont_run_id, inverse_of: :flowcells
    belongs_to :library, foreign_key: :ont_library_id, inverse_of: :flowcell
    delegate :requests, to: :library

    validates :position,
              presence: true,
              uniqueness: { scope: :ont_run_id,
                            message: 'should only appear once within run' }

    # Make table. We don't want anything pushing to it.
    def readonly?
      true
    end
  end
end

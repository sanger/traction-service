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

    def self.includes_args(except = nil)
      args = []
      args << { library: Ont::Library.includes_args(:flowcell) } unless except == :library
      args << { run: Ont::Run.includes_args(:flowcells) } unless except == :run

      args
    end
  end
end

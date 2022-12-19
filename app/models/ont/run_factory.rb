# frozen_string_literal: true

module Ont
  # Ont::RunFactory
  class RunFactory
    include ActiveModel::Model

    attr_accessor :run

    def create_run
      # puts run.flowcells
    end
  end
end

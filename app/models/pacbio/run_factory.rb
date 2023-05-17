# frozen_string_literal: true

module Pacbio
  # Create or update a run
  class RunFactory
    include ActiveModel::Model

    def run
      @run ||= Pacbio::Run.new
    end
  end
end

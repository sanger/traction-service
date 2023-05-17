# frozen_string_literal: true

module Pacbio
  # Create or update a run
  class RunFactory
    include ActiveModel::Model

    # attr_accessor :run, :well_attributes
    attr_accessor :well_attributes

    def construct_resources!; end
  end
end

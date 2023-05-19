# frozen_string_literal: true

module Pacbio
  # Create or update a run
  class RunFactory
    include ActiveModel::Model
    extend NestedValidation

    attr_accessor :run_attributes, :well_attributes

    validates_nested :run

    def construct_resources!
      ApplicationRecord.transaction do
        run.save!
        plate.save!
      end
    end

    def run
      @run ||= Pacbio::Run.new(run_attributes)
    end

    def plate
      @plate ||= run.plates.build(run:, well_attributes:)
    end
  end
end

# frozen_string_literal: true

module Pipelines
  # An accessor for constant values in the pipeline for configuration options
  class ConstantsAccessor
    def initialize(base)
      @constants_base = base
    end

    def external_study_id
      @constants_base.external_study_id
    end

    def species
      @constants_base.species
    end

    def instrument_name
      @constants_base.instrument_name
    end
  end
end

# frozen_string_literal: true

module Pipelines
  # An accessor for constant values in the pipeline for configuration options
  class ConstantsAccessor
    def initialize(base)
      @constants_base = base
    end

    def pcr_tag_set_name
      @constants_base.pcr_tag_set_name
    end
  end
end

# frozen_string_literal: true

module V1
    module Ont
      # TagSetResource
      class TagSetResource < V1::TagSetResource
        filter :pipeline, default: :ont
  
        # Ensure that any tag sets created via this endpoint are scoped to the
        # ont pipeline
        def self.create_model
          _model_class.ont_pipeline.new
        end
      end
    end
  end
  
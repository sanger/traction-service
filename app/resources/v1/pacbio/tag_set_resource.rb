# frozen_string_literal: true

module V1
  module Pacbio
    # TagSetResource
    class TagSetResource < V1::TagSetResource
      filter :pipeline, default: :pacbio

      # Ensure that any tag sets created via this endpoint are scoped to the
      # pacbio pipeline
      def self.create_model
        _model_class.pacbio_pipeline.new
      end
    end
  end
end

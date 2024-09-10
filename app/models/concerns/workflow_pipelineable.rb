# frozen_string_literal: true

# Include in records to associate them with a pipeline via an enum
module WorkflowPipelineable
  extend ActiveSupport::Concern

  included do
    enum pipeline: { pacbio: 0, ont: 1, extraction: 2, sample_qc: 3, hic: 4, bio_nano: 5 }.freeze
  end

  class_methods do
    def workflow_pipelines
      pipelines.keys
    end
  end
end

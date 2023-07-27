# frozen_string_literal: true

# Include in records to associate them with a pipeline via an enum
module Pipelineable
  extend ActiveSupport::Concern

  included do
    enum pipeline: Pipelines::NAMES, _suffix: true

    delegate :request_factory, to: :pipeline_handler
  end

  def pipeline_handler
    Pipelines.handler(pipeline)
  end
end

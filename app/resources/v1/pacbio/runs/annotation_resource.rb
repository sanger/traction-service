# frozen_string_literal: true

module V1
  # Provides a JSON:API resource of {Annotation} model.
  # Refer to {V1::AnnotationResource} for the base resource.
  #
  # @note Access this resource via the `/v1/pacbio/runs/:run_id/annotations` endpoint.
  #
  # @note It allows viewing of annotations, creation, updates and deletions are not permitted
  # via the API.
  #
  # @example
  #   curl -X GET http://localhost:3100/v1/pacbio/runs/1/annotations/1
  #   curl -X GET http://localhost:3100/v1/pacbio/runs/1/annotations/
  #
  module Pacbio
    module Runs
      class AnnotationResource < V1::AnnotationResource
      end
    end
  end
end

# frozen_string_literal: true

module V1
  # Provides a JSON:API representation of {Workflow}.
  #
  # @note Access this resource via the `/v1/workflows` endpoint.
  #
  # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
  # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package for the service
  # implementation of the JSON:API standard.
  #
  ## Primary Relationships:
  # * workflow_steps { V1::WorkflowStep }
  # @example
  #   curl -X GET http://localhost:3100/v1/workflows/1
  #   curl -X GET http://localhost:3100/v1/workflows/
  #   curl -X GET "http://localhost:3100/v1/workflows?include=workflow_steps"
  #
  class WorkflowResource < JSONAPI::Resource
    # @!attribute [rw] name
    #   @return [String] the name of the workflow
    # @!attribute [rw] pipeline
    #   @return [String] the pipeline of the workflow
    attributes :name, :pipeline

    # Define the relationship with workflow steps
    has_many :workflow_steps
  end
end

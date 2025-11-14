# frozen_string_literal: true

module V1
  # Provides a JSON:API representation of {WorkflowStep}.
  #
  # @note This resource cannot be accessed via the `/v1/workflow_steps` endpoint.
  # It is only accessible via the nested route under Workflow using includes.
  #
  class WorkflowStepResource < JSONAPI::Resource
    # @!attribute [rw] code
    #   @return [String] the code of the workflow step
    # @!attribute [rw] stage
    #   @return [String] the stage of the workflow step
    attributes :code, :stage

    # Define the relationship with workflow
    has_one :workflow
  end
end

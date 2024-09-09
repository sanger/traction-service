module V1
  # Provides a JSON:API representation of {Workflow}.
  #
  # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
  # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package for the service
  # implementation of the JSON:API standard.
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

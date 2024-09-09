module V1
  # Provides a JSON:API representation of {WorkflowStep}.
  #
  # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
  # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package for the service
  # implementation of the JSON:API standard.
  class WorkflowStepResource < JSONAPI::Resource
    # @!attribute [rw] code
    #   @return [String] the code of the workflow step
    # @!attribute [rw] stage
    #   @return [String] the stage of the workflow step
    attributes :code, :stage

    # Define the relationship with workflow
    has_one :workflow

    # Define a custom attribute "value" that returns the same value as "code"
    attribute :value do
      @model.code
    end

    # Define a custom attribute "description" that returns "code - stage"
    attribute :description do
      "#{@model.code} - #{@model.stage}"
    end
  end
end

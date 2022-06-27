# frozen_string_literal: true

module V1::Shared
  # Include in a resource to add the run suitability attribute which evalutates
  # if the resource can be used to generate a run. It does this by:
  # - Calling valid? in the run_creation context
  #   @see https://guides.rubyonrails.org/active_record_validations.html#on
  # - Uses the JsonAPI resources ValidationErrors object to generate JSON-API
  #   compatible errors objects. Status is removed as it is not relevant in
  #   this context. @see https://jsonapi.org/format/#error-objects
  module RunSuitability
    extend ActiveSupport::Concern

    included do
      attribute :run_suitability, readonly: true
    end

    def run_suitability
      {
        ready_for_run: @model.valid?(:run_creation),
        errors: inline_errors_object
      }
    end

    private

    def inline_errors_object
      JSONAPI::Exceptions::ValidationErrors.new(self).errors.as_json.map do |err|
        err.except('status')
      end
    end
  end
end

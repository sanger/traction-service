# frozen_string_literal: true

module Pipelines
  module Requestor
    # Model - behaviour for pipeline requests model
    module Resource
      extend ActiveSupport::Concern

      # Resource ClassMethods
      module ClassMethods
        # Use the parent_name method in resource which is equivalent to module_path
        # Something to keey an eye on.
        def pipeline
          @pipeline ||= parent_name.demodulize
        end

        def pipeline_const
          @pipeline_const ||= pipeline.constantize
        end

        def request_model
          @request_model ||= "#{pipeline}::Request"
        end
      end

      included do
        model_name request_model

        attributes(*pipeline_const.request_attributes, :sample_name)
      end
    end
  end
end

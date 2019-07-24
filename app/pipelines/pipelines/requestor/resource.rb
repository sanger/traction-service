# frozen_string_literal: true

module Pipelines
  module Requestor
    # Model - behaviour for pipeline requests model
    # includes the model name of the resource and the attributes
    # required for the resource
    module Resource
      extend ActiveSupport::Concern

      # Resource ClassMethods
      module ClassMethods
        # Use the parent_name method in resource which is equivalent to module_path
        # Something to keey an eye on.
        # @return [String] the name of the pipeline e.g. 'Pacbio'
        def pipeline
          @pipeline ||= parent_name.demodulize # 'Saphyr'
        end

        # @return [Constant] the constant of the pipeline e.g. Pacbio
        def pipeline_const
          @pipeline_const ||= pipeline.constantize
        end

        # @return [String] the name of the pipeline request e.g. 'Pacbio::Request'
        def request_model
          @request_model ||= "#{pipeline}::Request"
        end
      end

      included do
        model_name request_model

        attributes(*pipeline_const.request_attributes, :sample_name, :barcode)

        def barcode
          @model&.tube&.barcode
        end

        # def fetchable_fields
        #   if (@model.tube.pipeline == Saphyr)
        #     super + Saphyr.request_attributes
        #   else
        #     super
        #   end
        # end

        # def request_attributes
        #   @model.class.parent_name.constantize.request_attributes.reduce({}) do |memo, val|
        #     memo[val] = @model.send(val)
        #     memo
        #   end
        # end

      end
    end
  end
end

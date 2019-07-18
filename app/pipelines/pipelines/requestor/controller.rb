# frozen_string_literal: true

module Pipelines
  module Requestor
    # Controller - behaviour for pipeline requests controller
    module Controller
      extend ActiveSupport::Concern

      # Model ClassMethods
      module ClassMethods
        # @return [String] the name of the module
        #  e.g. +module_path(V1::Pacbio::Controller) = 'V1::Pacbio'+
        def module_path
          @module_path ||= name.to_s.deconstantize
        end

        # @return [String] the name of the pipeline
        #  e.g. +pipeline('V1::Pacbio') = 'Pacbio'+
        def pipeline
          @pipeline ||= module_path.demodulize
        end

        # @return [Constant] the pipeline
        #  e.g. +pipeline_const('Pacbio') = Pacbio+
        def pipeline_const
          @pipeline_const ||= pipeline.constantize
        end

        # @return [Constant] the factory to create requests for the pipeline
        #  e.g. +request_factory_model('Pacbio') = Pacbio::RequestFactory+
        def request_factory_model
          @request_factory_model ||= "::#{pipeline}::RequestFactory".constantize
        end

        # @return [Constant] the ActiveRecord model for requests for the pipeline
        #  e.g. +request_model('Pacbio') = Pacbio::Request+
        def request_model
          @request_model ||= "::#{pipeline}::Request".constantize
        end

        # @return [Constant] the JSON API resource model for requests for the pipeline
        #  e.g. +resource_model('V1::Pacbio') = Pacbio::RequestResource+
        def resource_model
          "#{module_path}::RequestResource".constantize
        end
      end

      # create action for the pipeline requests
      # uses the request factory
      def create
        if request_factory.save
          render json: body, status: :created
        else
          render json: { data: { errors: @request_factory.errors.messages } },
                 status: :unprocessable_entity
        end
      end

      # @return [Object] new request factory initialized with request params
      def request_factory
        @request_factory ||= self.class.request_factory_model.new(params_names)
      end

      # @return [Array] an array of request resources built on tne requestables
      def resources
        @resources ||= request_factory.requestables.map do |request|
          self.class.resource_model.new(request, nil)
        end
      end

      # @return [Hash] the body of the response; serialized resources
      def body
        @body ||= JSONAPI::ResourceSerializer.new(
          self.class.resource_model
        ).serialize_to_hash(resources)
      end

      # destroy action for the pipeline request
      def destroy
        pipeline_request.destroy
        head :no_content
      rescue StandardError => e
        render json: { data: { errors: e.message } }, status: :unprocessable_entity
      end

      # Finds request based on the id, used by destroy or edit
      # @return [ActiveRecord Object] e.g. +Pacbio::Request.find(1)
      def pipeline_request
        @pipeline_request = (params[:id] && self.class.request_model.find_by(id: params[:id]))
      end

      # Permitted parameters for create and edit actions
      # @return [ActionController::Parameters] - whitelisted
      def params_names
        params.require(:data).require(:attributes)[:requests].map do |param|
          param.permit(*self.class.pipeline_const.request_attributes,
                       :name, :external_id, :species).to_h
        end
      end
    end
  end
end

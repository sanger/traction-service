module Pipelines
  module Requestor
    # Controller - behaviour for pipeline requests factory
    module Controller
      extend ActiveSupport::Concern

      # Model ClassMethods
      module ClassMethods
        def module_path
          @module_path ||= name.to_s.deconstantize
        end

        def pipeline
          @pipeline ||= module_path.split('::').last
        end

        def pipeline_const
          @pipeline_const ||= pipeline.constantize
        end

        def request_factory_model
          @request_factory_model ||= "::#{pipeline}::RequestFactory".constantize
        end

        def request_model
          @request_model ||= "::#{pipeline}::Request".constantize
        end

        def resource_model
          "#{module_path}::RequestResource".constantize
        end
      end

      def create
        if request_factory.save
          render json: body, status: :created
        else
          render json: { data: { errors: @request_factory.errors.messages } },
                 status: :unprocessable_entity
        end
      end

      def request_factory
        @request_factory ||= self.class.request_factory_model.new(params_names)
      end

      def resources
        @resources ||= request_factory.requestables.map do |request|
          self.class.resource_model.new(request, nil)
        end
      end

      def body
        @body ||= JSONAPI::ResourceSerializer.new(
          self.class.resource_model
        ).serialize_to_hash(resources)
      end

      def destroy
        pipeline_request.destroy
        head :no_content
      rescue StandardError => e
        render json: { data: { errors: e.message } }, status: :unprocessable_entity
      end

      def pipeline_request
        @pipeline_request = (params[:id] && self.class.request_model.find_by(id: params[:id]))
      end

      def params_names
        params.require(:data).require(:attributes)[:requests].map do |param|
          param.permit(*self.class.pipeline_const.attributes, :name, :external_id, :species).to_h
        end
      end
    end
  end
end
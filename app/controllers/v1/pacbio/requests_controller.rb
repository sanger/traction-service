# frozen_string_literal: true

module V1
  module Pacbio
    # RequestsController
    class RequestsController < ApplicationController
      def create
        @request_factory = ::Pacbio::RequestFactory.new(params_names)

        if @request_factory.save

          @resources = @request_factory.requestables.map do |request|
            RequestResource.new(request, nil)
          end
          body = JSONAPI::ResourceSerializer.new(RequestResource).serialize_to_hash(@resources)
          render json: body, status: :created
        else
          render json: { data: { errors: @request_factory.errors.messages } },
                 status: :unprocessable_entity
        end
      end

      def destroy
        pipeline_request.destroy
        head :no_content
      rescue StandardError => e
        render json: { data: { errors: e.message } }, status: :unprocessable_entity
      end

      private

      def pipeline_request
        @pipeline_request = (params[:id] && ::Pacbio::Request.find_by(id: params[:id]))
      end

      def params_names
        params.require(:data).require(:attributes)[:requests].map do |param|
          param.permit(:library_type, :estimate_of_gb_required, :number_of_smrt_cells, :cost_code,
                       :external_study_id, :name, :external_id, :species).to_h
        end
      end
    end
  end
end

# frozen_string_literal: true

module V1
  module Saphyr
    # RequestsController
    class RequestsController < ApplicationController
      def create
        @request_factory = ::Saphyr::RequestFactory.new(params_names)

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
        pacbio_request.destroy
        head :no_content
      rescue StandardError => e
        render json: { data: { errors: e.message } }, status: :unprocessable_entity
      end

      private

      def pacbio_request
        @pacbio_request = (params[:id] && ::Saphyr::Request.find_by(id: params[:id]))
      end

      def params_names
        params.require(:data).require(:attributes)[:requests].map do |param|
          param.permit(:external_study_id, :name, :external_id, :species).to_h
        end
      end
    end
  end
end

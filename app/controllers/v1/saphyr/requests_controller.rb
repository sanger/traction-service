# frozen_string_literal: true

module V1
  module Saphyr
    # RequestsController
    class RequestsController < ApplicationController
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
        @request_factory ||= ::Saphyr::RequestFactory.new(params_names)
      end

      # @return [Array] an array of request resources built on tne requestables
      def resources
        @resources ||= request_factory.requestables.map do |request|
          Saphyr::RequestResource.new(request, nil)
        end
      end

      # @return [Hash] the body of the response; serialized resources
      def body
        @body ||= serialize_array(resources)
      end

      # destroy action for the pipeline request
      def destroy
        pipeline_request.destroy
        head :no_content
      rescue StandardError => e
        render json: { data: { errors: e.message } }, status: :unprocessable_entity
      end

      # Finds request based on the id, used by destroy or edit
      # @return [ActiveRecord Object] e.g. +Saphyr::Request.find(1)
      def pipeline_request
        @pipeline_request = (params[:id] && ::Saphyr::Request.find_by(id: params[:id]))
      end

      # Permitted parameters for create and edit actions
      # @return [Hash] - hash of permitted parameters
      def params_names
        params.require(:data).require(:attributes)
              .permit(
                requests: [
                  {
                    request: ::Saphyr.request_attributes,
                    sample: %i[name external_id species],
                    tube: :barcode
                  }
                ]
              ).to_h[:requests]
      end
    end
  end
end

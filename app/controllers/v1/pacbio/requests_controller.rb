# frozen_string_literal: true

module V1
  module Pacbio
    # RequestsController
    class RequestsController < ApplicationController
      # @return [Constant] the ActiveRecord model for requests for the pipeline
      #  e.g. +request_model('Pacbio') = Pacbio::Request+
      def self.request_model
        @request_model ||= ::Pacbio::Request
      end

      # @return [Object] new request factory initialized with request params
      def self.request_factory_model
        @request_factory_model ||= ::Pacbio::RequestFactory
      end

      # @return [Constant] the JSON API resource model for requests for the pipeline
      #  e.g. +resource_model('V1::Pacbio') = Pacbio::RequestResource+
      def self.resource_model
        @resource_model ||= Pacbio::RequestResource
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
        @body ||= serialize_array(resources)
      end

      # Finds request based on the id, used by destroy or edit
      # @return [ActiveRecord Object] e.g. +Pacbio::Request.find(1)
      def pipeline_request
        @pipeline_request = (params[:id] && self.class.request_model.find_by(id: params[:id]))
      end

      # destroy action for the pipeline request
      def destroy
        # binding.pry
        pipeline_request.destroy
        head :no_content
      rescue StandardError => e
        render json: { data: { errors: e.message } }, status: :unprocessable_entity
      end

      # Permitted parameters for create and edit actions
      # @return [Hash] - hash of permitted parameters
      def params_names
        params.require(:data).require(:attributes)
              .permit(
                requests: [
                  {
                    request: ::Pacbio.request_attributes,
                    sample: %i[name external_id species],
                    tube: :barcode
                  }
                ]
              ).to_h[:requests]
      end
    end
  end
end

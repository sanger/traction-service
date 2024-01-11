# frozen_string_literal: true

module V1
  module Pacbio
    # RequestsController
    # TODO: Move to request resource as per pool
    class RequestsController < ApplicationController
      # destroy action for the pipeline request
      def destroy
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

      private

      # Finds request based on the id, used by destroy or edit
      # @return [ActiveRecord Object] e.g. +Pacbio::Request.find(1)
      def pipeline_request
        @pipeline_request = params[:id] && ::Pacbio::Request.find_by(id: params[:id])
      end
    end
  end
end

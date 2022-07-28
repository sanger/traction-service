# frozen_string_literal: true

module V1
  module Saphyr
    # RequestsController
    class RequestsController < ApplicationController
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
    end
  end
end

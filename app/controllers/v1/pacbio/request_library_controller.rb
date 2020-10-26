# frozen_string_literal: true

module V1
  module Pacbio
    # RequestLibraryController
    class RequestLibraryController < ApplicationController
      def update
        request_library.update(request_library_update_params)
        render_json(:ok)
      rescue StandardError => e
        render json: { data: { errors: e.message } }, status: :unprocessable_entity
      end

      private

      def request_library
        @request_library = (params[:id] && ::Pacbio::RequestLibrary.find_by(id: params[:id]))
      end

      def request_library_update_params
        params.require(:data).require(:attributes)
              .permit(:tag_id)
      end

      def render_json(status)
        render json:
            JSONAPI::ResourceSerializer.new(RequestLibraryResource)
                                       .serialize_to_hash(RequestLibraryResource
                                       .new(@request_library, nil)), status: status
      end
    end
  end
end

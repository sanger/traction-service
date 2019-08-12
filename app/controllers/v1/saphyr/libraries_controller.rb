# frozen_string_literal: true

module V1
  module Saphyr
    # LibrariesController
    class LibrariesController < ApplicationController
      before_action :current_library, only: [:destroy]

      def create
        @library_factory = ::Saphyr::LibraryFactory.new(params_names)
        if @library_factory.save
          @resources = @library_factory.libraries.map { |lib| LibraryResource.new(lib, nil) }
          body = JSONAPI::ResourceSerializer.new(LibraryResource).serialize_to_hash(@resources)
          render json: body, status: :created
        else
          render json: { data: { errors: @library_factory.errors.messages } },
                 status: :unprocessable_entity
        end
      end

      def destroy
        if @library.deactivate
          head :no_content
        else
          render json: { data: { errors: @library.errors.messages } }, status: :unprocessable_entity
        end
      end

      private

      def current_library
        @library = (params[:id] && ::Saphyr::Library.find_by(id: params[:id]))
      end

      def params_names
        params.require(:data).require(:attributes)[:libraries].map do |param|
          param.permit(:state, :saphyr_request_id, :saphyr_enzyme_id).to_h
        end
      end
    end
  end
end

# frozen_string_literal: true

module V1
  module Saphyr
    # LibrariesController
    class LibrariesController < ApplicationController
      before_action :current_library, only: [:destroy]

      # This endpoint is not strictly JSON API compliant:
      # https://jsonapi.org/format/#crud-creating
      #   A resource can be created by sending a POST request to a URL that represents a collection
      #   of resources. The request MUST include a single resource object as primary data. The
      #   resource object MUST contain at least a type member.
      #
      # Here we may return multiple libraries. To be compliant I think it would need to return a
      # library_collection (or similar), but it doesn't sound like we'd need to provide an id.
      def create
        @library_factory = ::Saphyr::LibraryFactory.new(params_names)
        if @library_factory.save
          @resources = @library_factory.libraries.map { |lib| LibraryResource.new(lib, nil) }
          body = serialize_array(@resources)
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
        @library = params[:id] && ::Saphyr::Library.find_by(id: params[:id])
      end

      def params_names
        params.require(:data).require(:attributes)[:libraries].map do |param|
          param.permit(:state, :saphyr_request_id, :saphyr_enzyme_id).to_h
        end
      end
    end
  end
end

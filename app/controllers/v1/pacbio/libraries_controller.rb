# frozen_string_literal: true

module V1
  module Pacbio
    # LibrariesController
    class LibrariesController < ApplicationController
      def create
        @library_factory = ::Pacbio::LibraryFactory.new(params_names)
        if @library_factory.save
          @resources = @library_factory.libraries.map { |lib| LibraryResource.new(lib, nil) }
          body = JSONAPI::ResourceSerializer.new(LibraryResource).serialize_to_hash(@resources)
          render json: body, status: :created
        else
          render json: { data: { errors: @library_factory.errors.messages } },
                 status: :unprocessable_entity
        end
      end

      def update
        library.update(params_names)
        render_json(:ok)
      rescue StandardError => e
        render json: { data: { errors: e.message } }, status: :unprocessable_entity
      end

      def destroy
        library.destroy
        head :no_content
      rescue StandardError => e
        render json: { data: { errors: e.message } }, status: :unprocessable_entity
      end

      private

      def library
        @library = (params[:id] && ::Pacbio::Library.find_by(id: params[:id]))
      end

      def params_names
        params.require(:data).require(:attributes)[:libraries].map do |param|
          param.permit(:volume, :concentration, :library_kit_barcode, :fragment_size,
                       :pacbio_tag_id, :pacbio_request_id).to_h
        end
      end

      def render_json(status)
        render json:
           JSONAPI::ResourceSerializer.new(LibraryResource)
                                      .serialize_to_hash(LibraryResource.new(@library, nil)),
               status: status
      end
    end
  end
end

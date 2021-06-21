# frozen_string_literal: true

module V1
  module Pacbio
    # LibrariesController
    class LibrariesController < ApplicationController
      def create
        @library_factory = ::Pacbio::LibraryFactory.new(params_names)
        if @library_factory.save
          @resources = LibraryResource.new(@library_factory.library, nil)
          render json: serialize_resource(@resources), status: :created
        else
          render json: { data: { errors: @library_factory.errors.messages } },
                 status: :unprocessable_entity
        end
      end

      def update
        library.update(library_update_params)
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

      # TODO: abtsract behaviour for params names into separate library.
      def params_names
        attributes.merge(relationships)
      end

      def attributes
        params.require(:data).require(:attributes)
              .permit(:volume, :concentration, :template_prep_kit_box_barcode,
                      :fragment_size, :relationships, :request_id, :tag_id)
              .to_h
      end

      def relationships
        relationships_data = params.require(:data).require(:relationships)
        {
          pacbio_request_id: relationships_data.dig(:request, :data, :id),
          tag_id: relationships_data.dig(:tag, :data, :id)
        }
      end

      # necessary so only certain library params can be updated without
      # having to send unneccessary data in body of request
      def library_update_params
        params.require(:data).require(:attributes)
              .permit(:volume, :concentration, :template_prep_kit_box_barcode, :fragment_size)
      end

      def render_json(status)
        render json: serialize_resource(LibraryResource.new(@library, nil)),
               status: status
      end
    end
  end
end

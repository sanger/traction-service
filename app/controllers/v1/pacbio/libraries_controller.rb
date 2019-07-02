# frozen_string_literal: true

module V1
  module Pacbio
    # LibrariesController
    class LibrariesController < ApplicationController
      # before_action :current_library, only: [:destroy]

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

      private

      def params_names
        params.require(:data).require(:attributes)[:libraries].map do |param|
          param.permit(:volume, :concentration, :library_kit_barcode, :fragment_size,
                       :pacbio_tag_id, :sample_id).to_h
        end
      end
    end
  end
end

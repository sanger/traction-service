# frozen_string_literal: true

module V1
  module Pacbio
    module Wells
      # Wells::LibrariesController
      class LibrariesController < ApplicationController
        def create
          @library_factory = ::Pacbio::WellLibraryFactory.new(well, params_names)
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

        def well
          @well = (params[:well_id] && ::Pacbio::Well.find_by(id: params[:well_id]))
        end

        def params_names
          params.require(:data).require(:relationships)[:libraries].require(:data).map do |library|
            library.permit(:type, :id).to_h
          end.flatten
        end
      end
    end
  end
end

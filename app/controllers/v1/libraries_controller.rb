module V1
  class LibrariesController < ApplicationController

    def create
      @library_factory = LibraryFactory.new(params_names)
      if @library_factory.save
        @library_resources = @library_factory.libraries.map { |lib| LibraryResource.new(lib, nil)}
        render json: JSONAPI::ResourceSerializer.new(LibraryResource).serialize_to_hash(@library_resources), status: :created
      else
        render json: { errors: @library_factory.errors.messages}, status: :unprocessable_entity
      end
    end

    def params_names
      params.require(:data).require(:attributes)[:libraries].map { |param| param.permit(:state, :sample_id).to_h }
    end

  end
end

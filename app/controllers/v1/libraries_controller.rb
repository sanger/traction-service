# frozen_string_literal: true

module V1
  # LibrariesController
  class LibrariesController < ApplicationController
    def create
      @library_factory = LibraryFactory.new(params_names)
      if @library_factory.save
        @resources = @library_factory.libraries.map { |lib| LibraryResource.new(lib, nil) }
        body = JSONAPI::ResourceSerializer.new(LibraryResource).serialize_to_hash(@resources)
        render json: body, status: :created
      else
        render json: { errors: @library_factory.errors.messages }, status: :unprocessable_entity
      end
    end

    def params_names
      params.require(:data).require(:attributes)[:libraries].map do |param|
        param.permit(:state, :sample_id).to_h
      end
    end
  end
end

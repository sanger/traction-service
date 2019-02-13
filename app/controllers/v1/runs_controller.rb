# frozen_string_literal: true

module V1
  # RunsController
  class RunsController < ApplicationController

    def index
      @runs = Run.active
      @resources = @runs.map { |run| RunResource.new(run, nil) }
      body = JSONAPI::ResourceSerializer.new(RunResource).serialize_to_hash(@resources)
      render json: body
    end

    def create
      @run_factory = RunFactory.new(params_names)
      if @run_factory.save
        @resources = @run_factory.runs.map { |run| RunResource.new(run, nil) }
        render json:
          JSONAPI::ResourceSerializer.new(RunResource).serialize_to_hash(@resources),
               status: :created
      else
        render json: { errors: @run_factory.errors.messages }, status: :unprocessable_entity
      end
    end

    def params_names
      params.require(:data).require(:attributes)[:runs].map do |param|
        param.permit(:state).to_h
      end
    end

  end

end

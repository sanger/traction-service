# frozen_string_literal: true

module V1
  # RunsController
  class RunsController < ApplicationController
    def index
      @runs = Run.active
      @resources = @runs.map { |run| RunResource.new(run, nil) }
      render json: serialize_resources(@resources)
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

    def update
      attributes = params.require(:data)['attributes'].permit(:state, :name)
      run.update(attributes)
      head :ok
    rescue StandardError => e
      render json: { errors: e.message }, status: :unprocessable_entity
    end

    def show
      @resource = RunResource.new(run, nil)
      render json: serialize_resources(@resource)
    end

    private

    def run
      @run ||= Run.find(params[:id])
    end

    def params_names
      params.require(:data).require(:attributes)[:runs].map do |param|
        param.permit(:state, :name).to_h
      end
    end

    def serialize_resources(resources)
      if params[:include].present?
        return JSONAPI::ResourceSerializer.new(RunResource,
                                               include: [params[:include]]).serialize_to_hash(
                                                 resources
                                               )
      end

      JSONAPI::ResourceSerializer.new(RunResource).serialize_to_hash(resources)
    end
  end
end

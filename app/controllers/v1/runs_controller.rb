# frozen_string_literal: true

module V1
  # RunsController
  class RunsController < ApplicationController
    def create
      @run = Run.new(params_names)
      if @run.save
        render json:
          JSONAPI::ResourceSerializer.new(RunResource).serialize_to_hash(RunResource.new(run, nil)),
               status: :created
      else
        render json: { data: { errors: @run.errors.messages } },
               status: :unprocessable_entity
      end
    end

    def update
      run.update(params_names)

      head :ok
    rescue StandardError => e
      render json: { data: { errors: e.message } }, status: :unprocessable_entity
    end

    def destroy
      if run.destroy
        head :no_content
      else
        render json: { data: { errors: run.errors.messages } }, status: :unprocessable_entity
      end
    end

    private

    def run
      @run ||= Run.find(params[:id])
    end

    def params_names
      params.require(:data)['attributes'].permit(:state, :name)
    end
  end
end

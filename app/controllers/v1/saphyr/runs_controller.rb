# frozen_string_literal: true

module V1
  module Saphyr
    # RunsController
    class RunsController < ApplicationController
      def create
        @run = ::Saphyr::Run.new(params_names)
        if @run.save
          render_json(:created)
        else
          render json: { data: { errors: @run.errors.messages } },
                 status: :unprocessable_entity
        end
      end

      def update
        run.update(params_names)
        Messages.publish(run.chip.flowcells, Pipelines.saphyr.message)
        render_json(:ok)
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
        @run ||= ::Saphyr::Run.find(params[:id])
      end

      def params_names
        params.require(:data)['attributes'].permit(:state, :name)
      end

      def render_json(status)
        render json:
         JSONAPI::ResourceSerializer.new(RunResource)
                                    .serialize_to_hash(RunResource.new(run, nil)),
               status: status
      end
    end
  end
end

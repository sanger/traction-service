# frozen_string_literal: true

module V1
  module Pacbio
    module Runs
      # PlatesController
      class PlatesController < ApplicationController
        def create
          @plate = ::Pacbio::Plate.new(params_names)
          if @plate.save
            render_json(:created)
          else
            render json: { data: { errors: @plate.errors.messages } },
                   status: :unprocessable_content
          end
        end

        def update
          plate.update(params_names)
          render_json(:ok)
        rescue StandardError => e
          render json: { data: { errors: e.message } }, status: :unprocessable_content
        end

        def destroy
          plate.destroy
          head :no_content
        rescue StandardError => e
          render json: { data: { errors: e.message } }, status: :unprocessable_content
        end

        private

        def params_names
          params.require(:data)['attributes'].permit(:pacbio_run_id)
        end

        def plate
          @plate ||= ::Pacbio::Plate.find(params[:id])
        end

        def render_json(status)
          render json: serialize_resource(PlateResource.new(@plate, nil)),
                 status:
        end
      end
    end
  end
end

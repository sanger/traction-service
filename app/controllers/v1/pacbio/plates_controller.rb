# frozen_string_literal: true

module V1
  module Pacbio
    # PlatesController
    class PlatesController < ApplicationController
      def create
        @plate = ::Pacbio::Plate.new(params_names)
        if @plate.save
          render_json(:created)
        else
          render json: { data: { errors: @plate.errors.messages } },
                 status: :unprocessable_entity
        end
      end

      def update
        plate.update(params_names)
        render_json(:ok)
      rescue StandardError => e
        render json: { data: { errors: e.message } }, status: :unprocessable_entity
      end

      def destroy
        plate.destroy
        head :no_content
      rescue StandardError => e
        render json: { data: { errors: e.message } }, status: :unprocessable_entity
      end

      private

      def params_names
        params.require(:data)['attributes'].permit(:pacbio_run_id, :barcode)
      end

      def plate
        @plate ||= ::Pacbio::Plate.find(params[:id])
      end

      def render_json(status)
        render json:
           JSONAPI::ResourceSerializer.new(PlateResource)
                                      .serialize_to_hash(PlateResource.new(@plate, nil)),
               status: status
      end
    end
  end
end

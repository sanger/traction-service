# frozen_string_literal: true

module V1
  module Pacbio
    # WellsController
    class WellsController < ApplicationController
      def create
        @well = ::Pacbio::Well.new(params_names)
        if @well.save
          render json:
            JSONAPI::ResourceSerializer.new(WellResource)
                                       .serialize_to_hash(WellResource.new(@well, nil)),
                 status: :created
        else
          render json: { data: { errors: @well.errors.messages } },
                 status: :unprocessable_entity
        end
      end

      def update
        well.update(params_names)
        render_json(:ok)
      rescue StandardError => e
        render json: { data: { errors: e.message } }, status: :unprocessable_entity
      end

      def destroy
        well.destroy
        head :no_content
      rescue StandardError => e
        render json: { data: { errors: e.message } }, status: :unprocessable_entity
      end

      private

      def params_names
        params.require(:data)['attributes'].permit(:movie_time, :insert_size, :row,
                                                   :on_plate_loading_concentration, :column,
                                                   :pacbio_plate_id, :comment, :sequencing_mode)
      end

      def well
        @well ||= ::Pacbio::Well.find(params[:id])
      end

      def render_json(status)
        render json:
         JSONAPI::ResourceSerializer.new(WellResource)
                                    .serialize_to_hash(WellResource.new(@well, nil)), status: status
      end
    end
  end
end

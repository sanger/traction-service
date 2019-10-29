# frozen_string_literal: true

module V1
  module Pacbio
    # WellsController
    class WellsController < ApplicationController
      def create
        @well_factory = ::Pacbio::WellFactory.new(params_names)
        puts params_names
        if @well_factory.save
          render json:
            JSONAPI::ResourceSerializer.new(WellResource)
                                       .serialize_to_hash(WellResource.new(@well_factory.wells.first, nil)),
                 status: :created
        else
          puts @well_factory.errors.messages
          render json: { data: { errors: @well_factory.errors.messages } },
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
        # params.require(:data)['attributes'].permit(:movie_time, :insert_size, :row,
        #                                            :on_plate_loading_concentration, :column,
        #                                            :pacbio_plate_id, :comment, :sequencing_mode)

        params.require(:data).require(:attributes)[:wells].map do |param|
          param.permit( :movie_time, :insert_size, :row,
                        :on_plate_loading_concentration, :column,
                        :pacbio_plate_id, :comment, :sequencing_mode)
        end
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

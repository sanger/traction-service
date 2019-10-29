# frozen_string_literal: true

module V1
  module Pacbio
    # WellsController
    class WellsController < ApplicationController
      def create
        @well_factory = ::Pacbio::WellFactory.new(params_names)
        if @well_factory.save
          @resources = @well_factory.wells.map { |well| WellResource.new(well, nil) }
          body = JSONAPI::ResourceSerializer.new(LibraryResource).serialize_to_hash(@resources)
          render json: body, status: :created
        else
          render json: { data: { errors: @well_factory.errors.messages } },
                 status: :unprocessable_entity
        end
      end

      def update
        well.update(param_names)
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

      def param_names
        params.require(:data)['attributes'].permit(:movie_time, :insert_size, :row,
                                                   :on_plate_loading_concentration, :column,
                                                   :pacbio_plate_id, :comment, :sequencing_mode)
      end

      def params_names
        params.require(:data).require(:attributes)[:wells].map do |param|
          well_params_names(param)
        end.flatten
      end

      def well_params_names(params)
        params.permit(:movie_time, :insert_size, :row,
                      :on_plate_loading_concentration, :column,
                      :comment, :sequencing_mode, :relationships).to_h.tap do |well|
          well[:plate] = plate_params_names(params) if params[:relationships].present?
        end
      end

      def plate_params_names(params)
        params.require(:relationships)[:plate].require(:data).permit(:id, :type).to_h
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

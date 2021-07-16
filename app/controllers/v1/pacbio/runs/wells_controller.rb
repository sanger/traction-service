# frozen_string_literal: true

module V1
  module Pacbio
    module Runs
      # WellsController
      class WellsController < ApplicationController
        def create
          @well_factory = ::Pacbio::WellFactory.new(create_params)

          if @well_factory.save
            publish_message
            render json: body, status: :created
          else
            render json: { data: { errors: @well_factory.errors.messages } },
                   status: :unprocessable_entity
          end
        end

        def update
          @well_factory = ::Pacbio::WellFactory.new([update_params])

          if @well_factory.save
            publish_message
            render json: body, status: :ok
          else
            render json: { data: { errors: @well_factory.errors.messages } },
                   status: :unprocessable_entity
          end
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

        def body
          resources = @well_factory.wells.map do |well_factory|
            WellResource.new(::Pacbio::Well.find(well_factory.id), nil)
          end
          serialize_array(resources)
        end

        def publish_message
          Messages.publish(@well_factory.plate, Pipelines.pacbio.message)
        end

        def update_params
          permitted_update_params.to_h.tap do |well_param|
            well_param[:id] = data_params[:id]
            if data_params[:relationships].present?
              well_param[:pools] =
                pool_param_names(data_params)
            end
          end
        end

        def permitted_update_params
          params.require(:data)
                .require(:attributes)
                .permit(
                  :movie_time, :insert_size, :row, :on_plate_loading_concentration,
                  :column, :comment, :id, :pre_extension_time, :generate_hifi,
                  :ccs_analysis_output
                )
        end

        def create_params
          params.require(:data).require(:attributes).fetch(:wells, []).map do |param|
            well_params_names(param)
          end
        end

        def well_params_names(well_params)
          well_params.permit(:movie_time, :insert_size, :row,
                             :on_plate_loading_concentration, :column,
                             :comment, :relationships,
                             :pre_extension_time, :generate_hifi,
                             :ccs_analysis_output).to_h.tap do |well|
            if well_params[:relationships].present?
              well[:plate] = plate_params_names(well_params)
              well[:pools] = pool_param_names(well_params) unless well_params.dig(:relationships,
                                                                                  :pools).nil?
            end
          end
        end

        def plate_params_names(params)
          params.require(:relationships)[:plate].require(:data).permit(:id, :type).to_h
        end

        def pool_param_names(params)
          params.require(:relationships)[:pools][:data].map do |pool|
            pool.permit(:id, :type).to_h
          end.flatten
        end

        def well
          @well ||= ::Pacbio::Well.find(params[:id])
        end

        def render_json(status)
          render json: serialize_resource(WellResource.new(@well, nil)),
                 status: status
        end

        def data_params
          params.require(:data)
        end
      end
    end
  end
end

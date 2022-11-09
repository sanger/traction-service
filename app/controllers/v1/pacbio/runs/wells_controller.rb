# frozen_string_literal: true

module V1
  module Pacbio
    module Runs
      # WellsController
      class WellsController < ApplicationController
        PERMITTED_WELL_PARAMETERS = %i[
          movie_time row on_plate_loading_concentration
          column comment pre_extension_time generate_hifi ccs_analysis_output
          binding_kit_box_barcode loading_target_p1_plus_p2
          ccs_analysis_output_include_low_quality_reads
          include_fivemc_calls_in_cpg_motifs
          ccs_analysis_output_include_kinetics_information
          demultiplex_barcodes
        ].freeze

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

        def permitted_update_params
          data_params.require(:attributes)
                     .permit(*PERMITTED_WELL_PARAMETERS, :id)
        end

        def update_params
          permitted_update_params.to_h.tap do |well|
            well[:id] = data_params[:id]
            well[:pools] = pool_param_names(data_params) if data_params.dig(:relationships, :pools)
          end
        end

        def create_params
          data_params.require(:attributes).fetch(:wells, []).map do |param|
            well_params_names(param)
          end
        end

        def well_params_names(well_params)
          well_params.permit(*PERMITTED_WELL_PARAMETERS).to_h.tap do |well|
            if well_params[:relationships].present?
              well[:plate] = plate_params_names(well_params)
              well[:pools] = pool_param_names(well_params) if well_params.dig(
                :relationships, :pools
              )
            end
          end
        end

        def plate_params_names(params)
          params.require(:relationships)
                .require(:plate)
                .require(:data).permit(:id, :type).to_h
        end

        def pool_param_names(params)
          params.require(:relationships)[:pools][:data].map do |pool|
            pool.permit(:id, :type).to_h
          end
        end

        def well
          @well ||= ::Pacbio::Well.find(params[:id])
        end

        def render_json(status)
          render json: serialize_resource(WellResource.new(@well, nil)),
                 status:
        end

        def data_params
          params.require(:data)
        end
      end
    end
  end
end

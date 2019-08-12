# frozen_string_literal: true

module V1
  module Pacbio
    # RunsController
    class RunsController < ApplicationController
      def create
        @run = ::Pacbio::Run.new(params_names)
        if @run.save
          render_json(:created)
        else
          render json: { data: { errors: @run.errors.messages } },
                 status: :unprocessable_entity
        end
      end

      def update
        run.update(params_names)
        render_json(:ok)
      rescue StandardError => e
        render json: { data: { errors: e.message } }, status: :unprocessable_entity
      end

      def destroy
        run.destroy
        head :no_content
      rescue StandardError => e
        render json: { data: { errors: e.message } }, status: :unprocessable_entity
      end

      # endpoint generating a sample sheet for a Pacbio::Run
      def sample_sheet
        run = ::Pacbio::Run.find(params[:run_id])
        csv = run.generate_sample_sheet

        send_data csv,
                  type: 'text/csv; charset=utf-8; header=present',
                  disposition: 'attachment; filename=sample_sheet.csv'
      end

      private

      def run
        @run ||= ::Pacbio::Run.find(params[:id])
      end

      def params_names
        params.require(:data)['attributes'].permit(:name, :template_prep_kit_box_barcode,
                                                   :binding_kit_box_barcode,
                                                   :sequencing_kit_box_barcode,
                                                   :dna_control_complex_box_barcode,
                                                   :system_name)
      end

      def render_json(status)
        render json:
         JSONAPI::ResourceSerializer.new(RunResource)
                                    .serialize_to_hash(RunResource.new(@run, nil)), status: status
      end
    end
  end
end

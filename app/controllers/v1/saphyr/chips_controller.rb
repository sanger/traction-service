# frozen_string_literal: true

module V1
  module Saphyr
    # ChipsController
    class ChipsController < ApplicationController
      def create
        @chip = ::Saphyr::Chip.new(params_names)
        if @chip.save
          render_json(:created)
        else
          render json: { data: { errors: @chip.errors.messages } },
                 status: :unprocessable_entity
        end
      end

      def update
        chip.update(params_names)
        Messages.publish(chip.flowcells, Pipelines.saphyr.message)
        render_json(:ok)
      rescue StandardError => e
        render json: { data: { errors: e.message } }, status: :unprocessable_entity
      end

      def destroy
        if chip.destroy
          head :no_content
        else
          render json: { data: { errors: chip.errors.messages } }, status: :unprocessable_entity
        end
      end

      private

      def params_names
        params.require(:data)['attributes'].permit(:barcode, :saphyr_run_id)
      end

      def chip
        @chip ||= ::Saphyr::Chip.find(params[:id])
      end

      def render_json(status)
        render json:
           JSONAPI::ResourceSerializer.new(ChipResource)
                                      .serialize_to_hash(ChipResource.new(chip, nil)),
               status: status
      end
    end
  end
end

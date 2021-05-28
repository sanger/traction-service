# frozen_string_literal: true

module V1
  module Pacbio
    # PlatesController
    class PlatesController < ApplicationController
      def create
        @plate_creator = ::Pacbio::PlateCreator.new(plates_params)
        if @plate_creator.save!
          @plates = @plate_creator.plates.map { |plate| PlateResource.new(plate, nil) }
          body = JSONAPI::ResourceSerializer.new(PlateResource).serialize_to_hash(@plates)
          render json: body, status: :created
        else
          render json: { data: { errors: @plate_creator.errors.messages } },
                 status: :unprocessable_entity
        end
      end

      private

      def plates_params
        params.require(:data)['attributes'].permit(
          plates: [:barcode, { wells: [:position, { samples:
              %i[name external_id species library_type estimate_of_gb_required
                 number_of_smrt_cells cost_code external_study_id] }] }]
        ).to_h
      end
    end
  end
end

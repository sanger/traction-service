# frozen_string_literal: true

module V1
  module Pacbio
    # PlatesController
    class PlatesController < ApplicationController
      # This endpoint is not strictly JSON API compliant:
      # https://jsonapi.org/format/#crud-creating
      #   A resource can be created by sending a POST request to a URL that represents a collection
      #   of resources. The request MUST include a single resource object as primary data. The
      #   resource object MUST contain at least a type member.
      #
      # Here we may return multiple libraries. To be compliant I think it would need to return a
      # library_collection (or similar), but it doesn't sound like we'd need to provide an id.
      def create
        @plate_creator = ::Pacbio::PlateCreator.new(plates_params)
        if @plate_creator.save!
          @plates = @plate_creator.plates.map { |plate| PlateResource.new(plate, nil) }
          body = serialize_array(@plates)
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
                 number_of_smrt_cells cost_code external_study_id qc_status] }] }]
        ).to_h
      end
    end
  end
end

# frozen_string_literal: true

# Ont namespace
module Ont
  # PlateBulkInserter
  # A service for bulk inserting a plate and all of its dependents
  class PlateBulkInserter
    def ont_request_data(ont_request, tag_id)
      {
        ont_request: serialise_ont_request(ont_request),
        tag_id: tag_id
      }
    end

    def well_data(well, request_data)
      {
        well: serialise_well(well),
        request_data: request_data
      }
    end

    def plate_data(plate, well_data)
      {
        plate: serialise_plate(plate),
        well_data: well_data
      }
    end

    private

    def serialise_ont_request(ont_request)
      # TODO: (2/05/2020) - implement
    end

    def serialise_well(well)
      # TODO: (28/05/2020) - implement
    end

    def serialise_plate(plate)
      # TODO: (28/05/2020) - implement
    end
  end
end

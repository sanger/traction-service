# frozen_string_literal: true

module Message
  # Message::Message
  # Creates a message in the correct structure for the warehouse
  class Message < DataStructureBuilder
    # Produces the message in the correct format
    # Example:
    #   {"lims"=>"Traction", "bmap_flowcell"=>{"sample_uuid"=>"5",
    #     "study_uuid"=>"5", "experiment_name"=>5, "enzyme_name"=>"Nb.BssSI",
    #     "chip_barcode"=>"FLEVEAOLPTOWPNWU20319131581014320190911XXXXXXXXXXXXX",
    #     "chip_serialnumber"=>"FLEVEAOLPTOWPNWU", "position"=>2, "id_library_lims"=>5,
    #     "id_flowcell_lims"=>10, "instrument_name"=>"saphyr",
    #     "last_updated"=>Mon, 12 Aug 2019 12:37:51 UTC +00:00}}
    def content
      { lims: configuration.lims }.with_indifferent_access.tap do |result|
        result[configuration.key] = data_structure
      end
    end

    # Content as json
    # Called by the message broker
    def payload
      content.to_json
    end
  end
end

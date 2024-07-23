# frozen_string_literal: true

module VolumeTracking
  # Message::Message
  # Creates a message in the correct structure for the warehouse
  class MessageBuilder < Message::Message
    # Produces the message in the correct format
    # Example:
    #   {"limsId"=>"Traction",
    #    "messageCreateDateUtc"=>Mon, 15 Jul 2024 15:16:54.877858000 UTC +00:00,
    #    "messageUuid"=>"0a62ee15-bbf6-46f0-ba95-01d42622d076",
    #    "recordedAt"=>Mon, 15 Jul 2024 15:16:54.867713000 UTC +00:00,
    #    "volume"=>1.5, "concentration"=>10.0, "insertSize"=>100, "aliquotType"=>"primary",
    #    "aliquotId"=>"", "sourceType"=>"library", "sourceBarcode"=>"TRAC-2-35805",
    #    "sampleName"=>"Sample1", "usedByBarcode"=>"TRAC-2-35806", "usedByType"=>"pool"}}

    def publish_data # rubocop:disable Metrics/MethodLength
      # Memoize the data
      return @publish_data if defined?(@publish_data)

      aliquot = object
      data = { source_type: '', source_barcode: '', sample_name: '',
               used_by_type: 'nil', used_by_barcode: '', aliquot_id: aliquot.id.to_s || '' }

      case aliquot.source_type
      when 'Pacbio::Library'
        data[:source_type] = 'library'
        data[:source_barcode] = aliquot.source.tube.barcode
        data[:sample_name] = aliquot.source.sample_name
      end

      case aliquot.used_by_type
      when 'Pacbio::Well'
        data[:used_by_type] = 'well'
        data[:used_by_barcode] =
          "#{aliquot.used_by.plate.sequencing_kit_box_barcode}:#{aliquot.used_by.plate.plate_number}:#{aliquot.used_by.position}" # rubocop:disable Layout/LineLength
      when 'Pacbio::Pool'
        data[:used_by_type] = 'pool'
        data[:used_by_barcode] = aliquot.used_by.tube.barcode
      end
      @publish_data = data
    end
  end
end

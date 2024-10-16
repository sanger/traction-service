# frozen_string_literal: true

module VolumeTracking
  # Creates a message in the correct structure for the warehouse
  # @example
  #   {
  #     "limsId"=>"Traction",
  #     "messageCreateDateUtc"=>Mon, 15 Jul 2024 15:16:54.877858000 UTC +00:00,
  #     "messageUuid"=>"0a62ee15-bbf6-46f0-ba95-01d42622d076",
  #     "recordedAt"=>Mon, 15 Jul 2024 15:16:54.867713000 UTC +00:00,
  #     "volume"=>1.5,
  #     "concentration"=>10.0,
  #     "insertSize"=>100,
  #     "aliquotType"=>"primary",
  #     "aliquotUuid"=>"",
  #     "sourceType"=>"library",
  #     "sourceBarcode"=>"TRAC-2-35805",
  #     "sampleName"=>"Sample1",
  #     "usedByBarcode"=>"TRAC-2-35806",
  #     "usedByType"=>"pool"
  #   }
  #
  class MessageBuilder < Message::Message
    def publish_data
      @publish_data ||= generate_publish_data
    end

    private

    def generate_publish_data
      data = base_data
      populate_by_source_type(data)
      populate_by_used_type(data)
      data
    end

    def base_data
      {
        source_type: '',
        source_barcode: '',
        sample_name: '',
        used_by_type: 'none',
        used_by_barcode: '',
        aliquot_uuid: object.uuid,
        message_uuid: SecureRandom.uuid
      }
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def populate_by_source_type(data)
      case object.source_type
      when 'Pacbio::Library'
        data[:source_type] = 'library'
        data[:source_barcode] = object.source.tube.barcode
        data[:sample_name] = object.source.sample_name
      when 'Pacbio::Pool'
        data[:source_type] = 'pool'
        data[:source_barcode] = object.source.tube.barcode
        data[:sample_name] = pacbio_library_sample_names
      when 'Pacbio::Request'
        data[:source_type] = 'request'
        data[:source_barcode] = if object.source.tube.nil?
                                  object.source.plate.barcode
                                else
                                  object.source.tube.barcode
                                end
        data[:source_barcode] = object.source.container.barcode
        data[:sample_name] = object.source.sample_name
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def populate_by_used_type(data)
      case object.used_by_type
      when 'Pacbio::Well'
        data[:used_by_type] = 'run'
        data[:used_by_barcode] = used_by_well_barcode
      when 'Pacbio::Pool'
        data[:used_by_type] = 'pool'
        data[:used_by_barcode] = object.used_by.tube.barcode
      when 'Pacbio::Request'
        data[:used_by_type] = 'request'
      end
    end

    def used_by_well_barcode
      "#{object.used_by.plate.sequencing_kit_box_barcode}:" \
        "#{object.used_by.plate.plate_number}:#{object.used_by.position}"
    end

    def pacbio_library_sample_names
      object.source.used_aliquots
            .select { |aliquot| aliquot.source.is_a?(Pacbio::Library) }
            .map(&:source)
            .map(&:sample)
            .map(&:name)
            .uniq
            .join(': ')
    end
  end
end

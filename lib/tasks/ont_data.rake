# frozen_string_literal: true

require 'securerandom'

namespace :ont_data do
  desc 'Populate the database with ont plates and tubes'
  task create: [:environment] do
    require 'factory_bot'
    # Ensure we've loaded our factories.
    FactoryBot.reload if FactoryBot.factories.count == 0

    number_of_plates = ENV.fetch('PLATES', 2).to_i
    number_of_tubes = ENV.fetch('TUBES', 2).to_i
    wells_per_plate = ENV.fetch('WELLS_PER_PLATE', 95).to_i

    library_types = LibraryType.ont_pipeline.pluck(:name).cycle
    data_types = DataType.ont_pipeline.pluck(:name).cycle
    timestamp = Time.now.to_i
    sample_names = (1..).lazy.map { |id| "GENSAMPLE-#{timestamp}-#{id}" }
    barcodes = (1..).lazy.map { |bc| "GEN-#{timestamp}-#{bc}" }

    well_positions = (1..12).flat_map { |r| ('A'..'H').map { |c| "#{c}#{r}" } }

    plates = number_of_plates.times.flat_map do
      barcode = barcodes.next
      library_type = library_types.next
      data_type = data_types.next
      well_positions.take(wells_per_plate).map do |position|
        {
          request: FactoryBot.attributes_for(:ont_request).merge(library_type:, data_type:),
          sample: FactoryBot.attributes_for(:sample, name: sample_names.next),
          container: { type: 'wells', barcode:, position: }
        }
      end
    end

    tubes = number_of_tubes.times.map do
      barcode = barcodes.next
      library_type = library_types.next
      data_type = data_types.next
      {
        request: FactoryBot.attributes_for(:ont_request).merge(library_type:, data_type:),
        sample: FactoryBot.attributes_for(:sample, name: sample_names.next),
        container: { type: 'tubes', barcode: }
      }
    end

    Reception.create!(
      source: 'traction-service.rake-task',
      request_attributes: [
        *plates,
        *tubes
      ]
    ).construct_resources!

    puts "-> Created requests for #{number_of_plates} plates and #{number_of_tubes} tubes"
  end
end

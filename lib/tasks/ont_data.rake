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

    # Creating ONT pools and libraries
    # Create 10 untagged single plexed pools

    # ont_tag_sets = TagSet.find_by_pipeline("ont")
    # if ont_tag_sets.nil?
    #   puts "-> Creating ONT tag sets"
    #   Rake::Task['tags:create:ont_all'].invoke
    # end
    temp_use_pacbio_tag_set = TagSet.find_by(pipeline: 'pacbio').tags
    requests = Ont::Request.all.limit(5)
    requests.each_with_index do |_req, i|
      Ont::Pool.create!(
        kit_number: i,
        volume: i,
        library_attributes: [
          {
            kit_number: i,
            volume: i,
            ont_request_id: requests.sample.id,
            tag_id: nil
          }
        ]
      )
    end

    puts "-> Created #{requests.length} single plexed pools"

    requests = Ont::Request.all.limit(10).offset(5)
    requests.each_with_index do |_req, i|
      Ont::Pool.create!(
        kit_number: i,
        volume: i,
        library_attributes: (0...rand(1..10)).map do |j|
          {
            kit_number: j,
            volume: j,
            ont_request_id: requests.sample.id,
            tag_id: temp_use_pacbio_tag_set[j].id
          }
        end
      )
    end

    puts "-> Created #{requests.length} multiplexed pools"
  end
end

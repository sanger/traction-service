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

    Rake::Task['tags:create:ont_all'].invoke
    ont_tag_set = TagSet.find_by(pipeline: 'ont')

    requests = Ont::Request.all.limit(5)
    requests.each_with_index do |req, i|
      Ont::Pool.create!(
        kit_barcode: "barcode-#{i}",
        volume: rand(1..10),
        concentration: rand(1..10),
        insert_size: rand(1000..10000),
        library_attributes: [
          {
            kit_barcode: "barcode-#{i}",
            volume: rand(1..10),
            concentration: rand(1..10),
            insert_size: rand(1000..10000),
            ont_request_id: req.id,
            tag_id: nil
          }
        ]
      )
    end

    puts "-> Created #{requests.length} single plexed pools"
    requests = Ont::Request.all.limit(10).offset(5)
    requests.each_with_index do |_req, i|
      Ont::Pool.create!(
        kit_barcode: "barcode-#{i}",
        volume: rand(1..10),
        concentration: rand(1..10),
        insert_size: rand(1000..10000),
        library_attributes: (0...rand(1..10)).map do |j|
          {
            kit_barcode: "barcode-#{i}",
            volume: rand(1..10),
            concentration: rand(1..10),
            insert_size: rand(1000..10000),
            ont_request_id: requests.sample.id,
            tag_id: ont_tag_set.tags[j].id
          }
        end
      )
    end

    puts "-> Created #{requests.length} multiplexed pools"

    # Peek helper that returns nil from enumerator instead of raising StopIteration
    def safe_peek(enumerator)
      enumerator.peek
    rescue StopIteration
      nil
    end

    # Run helper that creates runs for the specified instrument and flowcell count.
    # pool_enum enumerates available pools, state_enum enumerates run states, and
    # position_cycle enumerates flowcell positions for an instrument.
    def create_run(instrument, flowcell_count, pool_enum, state_enum, position_cycle)
      return if flowcell_count < 1
      return if flowcell_count > instrument.max_number_of_flowcells
      return if safe_peek(pool_enum).blank?

      run = Ont::Run.new(instrument:, state: state_enum.next)
      flowcell_count.times do
        break if safe_peek(pool_enum).blank?

        position = position_cycle.next
        flowcell_id = format('F%05d', position)
        Ont::Flowcell.new(flowcell_id:, position:, run:, pool: pool_enum.next)
      end
      run.save!
    end

    # Instruments
    Rake::Task['ont_instruments:create'].invoke
    gridion = Ont::Instrument.GridION.first
    promethion = Ont::Instrument.PromethION.first

    # MinKnowVersions
    Rake::Task['min_know_versions:create'].invoke

    # Enumerations
    pool_enum = Ont::Pool.where.missing(:flowcell).to_enum # Pools available
    state_enum = Ont::Run.states.keys.cycle # Run states
    gridion_cycle = (1..gridion.max_number_of_flowcells).cycle
    promethion_cycle = (1..promethion.max_number_of_flowcells).cycle

    # Create runs with the specified instrument and flowcell counts
    [1, 2, 2].each do |flowcell_count|
      create_run(gridion, flowcell_count, pool_enum, state_enum, gridion_cycle)
    end

    [1, 2, 4].each do |flowcell_count|
      create_run(promethion, flowcell_count, pool_enum, state_enum, promethion_cycle)
    end

    puts "-> Created #{Ont::Run.count} sequencing runs"
    puts "-> Created #{Ont::Flowcell.count} flowcells"
  end
end

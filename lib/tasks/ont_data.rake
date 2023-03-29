# frozen_string_literal: true

require 'securerandom'

namespace :ont_data do
  desc 'Populate the database with ont plates and tubes'
  task create: [:environment] do
    require_relative 'reception_generator'

    number_of_plates = ENV.fetch('PLATES', 2).to_i
    number_of_tubes = ENV.fetch('TUBES', 2).to_i
    wells_per_plate = ENV.fetch('WELLS_PER_PLATE', 95).to_i

    ReceptionGenerator.new(
      number_of_plates:,
      number_of_tubes:,
      wells_per_plate:,
      pipeline: :ont
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
    # pool_enum enumerates available pools, state_enum enumerates run states,
    # position_cycle enumerates flowcell positions for an instrument and
    # flowcell_id_enum enumerates numbers for flowcell_id values.
    # rubocop:disable Metrics/ParameterLists
    def create_run(instrument, flowcell_count, pool_enum, state_enum, position_cycle, flowcell_id_enum)
      return if flowcell_count < 1
      return if flowcell_count > instrument.max_number_of_flowcells
      return if safe_peek(pool_enum).blank?

      run = Ont::Run.new(instrument:, state: state_enum.next)
      flowcell_count.times do
        break if safe_peek(pool_enum).blank?

        position = position_cycle.next
        pool = pool_enum.next
        flowcell_id = format(Ont::Flowcell::FLOWCELL_ID_FORMAT, flowcell_id_enum.next)
        Ont::Flowcell.new(flowcell_id:, position:, run:, pool:)
      end
      run.save!
    end
    # rubocop:enable Metrics/ParameterLists

    # Instruments
    Rake::Task['ont_instruments:create'].invoke
    gridion = Ont::Instrument.GridION.first
    promethion = Ont::Instrument.PromethION.first

    # MinKnowVersions
    Rake::Task['min_know_versions:create'].invoke

    # Enumerations
    flowcell_id_enum = ((Ont::Flowcell.count + 1)..Ont::Pool.count).to_enum
    pool_enum = Ont::Pool.where.missing(:flowcell).to_enum # Pools available
    state_enum = Ont::Run.states.keys.cycle # Run states
    gridion_cycle = (1..gridion.max_number_of_flowcells).cycle
    promethion_cycle = (1..promethion.max_number_of_flowcells).cycle

    initial_run_count = Ont::Run.count
    initial_flowcell_count = Ont::Flowcell.count

    # Create runs with the specified instrument and flowcell counts
    [1, 2, 2].each do |flowcell_count|
      create_run(gridion, flowcell_count, pool_enum, state_enum, gridion_cycle, flowcell_id_enum)
    end

    [1, 2, 4].each do |flowcell_count|
      create_run(promethion, flowcell_count, pool_enum, state_enum, promethion_cycle, flowcell_id_enum)
    end

    puts "-> Created #{Ont::Run.count - initial_run_count} sequencing runs"
    puts "-> Created #{Ont::Flowcell.count - initial_flowcell_count} flowcells"
  end
end

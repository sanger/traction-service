# frozen_string_literal: true

# A set of GraphQL queries for creating ONT plates
module CreatePlateQueries
  def self.single_sample_well(position:, tag_set_id:, tag_index:)
    padded_tag_set_number = format('%<number>02i', { number: tag_set_id })
    padded_tag_number = format('%<number>02i', { number: tag_index })

    <<~WELL
      {
        position: "#{position}"
        samples: [
          {
            name: "Sample for #{position}"
            externalId: "#{position}-ExtId"
          }
        ]
      }
    WELL
  end

  def self.multi_sample_well(position:, num_samples:, tag_set_id:)
    samples = (1..num_samples).map do |sample_number|
      padded_sample_number = format('%<number>03i', { number: sample_number })
      padded_tag_set_number = format('%<number>02i', { number: tag_set_id })
      padded_tag_number = format('%<number>02i', { number: sample_number })

      <<~SAMPLE
        {
          name: "Sample #{padded_sample_number} for #{position}"
          externalId: "#{position}-#{padded_sample_number}-ExtId"
          tagGroupId: "dt#{padded_tag_set_number}_#{padded_tag_number}"
        }
      SAMPLE
    end

    <<~WELL
      {
        position: "#{position}"
        samples: [
          #{samples.join "\n"}
        ]
      }
    WELL
  end

  def self.wells(samples_per_well:, well_group_size:)
    well_positions = ((1..12).to_a.product %w[A B C D E F G H]).map { |pair| "#{pair[1]}#{pair[0]}" }

    wells = well_positions.each_slice(well_group_size).flat_map do |well_position_group|
      tag_set_id = 1
      wells_in_group = well_position_group.map do |position|
        if samples_per_well == 1
          self.single_sample_well position: position, tag_set_id: tag_set_id
        tag_set_id += 1
      end.join "\n"

      wells_in_group
    end



    if samples_per_well == 1

    else
      tag_set_id = 1
      wells = well_positions.each_slice(well_group_size).flat_map do |well_position_group|
        wells_in_group = well_position_group.map do |position|
          self.well position: position, num_samples: 1, tag_set_id: tag_set_id
          tag_set_id += 1
        end.join "\n"

        wells_in_group
      end
    end

    puts <<~GRAPHQL
      wells: [
        #{wells}
      ]
    GRAPHQL
    exit
  end

  PoolingScenario1 = TractionGraphQL::Client.parse <<~GRAPHQL
    mutation {
      createPlateWithOntSamples(
        input: {
          arguments: {
            barcode: "PLATE-1234"
            #{wells samples_per_well: 1, well_group_size: 24}
          }
        }
      ) { errors }
    }
  GRAPHQL
end

namespace :ont_runs do
  def submit_create_plate_query(query, description)
    puts "-> Creating a plate for #{description}"
    result = TractionGraphQL::Client.query query

    errors_array = result.original_hash['data']['createPlateWithOntSamples']['errors']
    if errors_array.any?
      puts "-> Failed to create plate for #{description}: #{errors_array}"
      exit
    end

    puts "-> Succesfully created a plate for #{description}"
  rescue Errno::ECONNREFUSED
    puts "-> Failed to connect to the Rails server at #{TractionGraphQL::RAILS_ROOT_URI}"
    puts '   Use the RAILS_ROOT_URI environment variable to specify a different URI'
    exit
  end

  task create: :environment do
    puts '-> Creating ONT runs using GraphQL'
    submit_create_plate_query(CreatePlateQueries::PoolingScenario1, 'pooling scenario 1')
    puts '-> Successfully create all ONT runs'
  end

  task destroy: :environment do
    Sample.all.each do |sample|
      sample.destroy if sample.requests[0].requestable_type == 'Ont::Request'
    end
    [Ont::Request].each(&:delete_all)
    puts '-> ONT runs successfully deleted'
  end
end

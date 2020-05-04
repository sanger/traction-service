# frozen_string_literal: true

# A set of GraphQL queries for creating ONT plates
module CreatePlateQueries
  def self.well(position:, num_samples:, tag_set_id: nil)
    samples = (1..num_samples).map do |sample_number|
      padded_sample_number = format('%<number>03i', { number: sample_number })

      unless num_samples == 1 || tag_set_id.nil?
        padded_tag_set_number = format('%<number>02i', { number: tag_set_id })
        padded_tag_number = format('%<number>02i', { number: sample_number })
        tag_group_id = "dt#{padded_tag_set_number}_#{padded_tag_number}"
      end

      sample_start = <<~SAMPLE
        {
          name: "Sample #{padded_sample_number} for #{position}"
          externalId: "#{position}-#{padded_sample_number}-ExtId"
      SAMPLE

      if tag_group_id.nil?
        "#{sample_start}}"
      else
        <<~SAMPLE
            #{sample_start}
            tagGroupId: "#{tag_group_id}"
          }
        SAMPLE
      end
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

  def self.wells(samples_per_well:)
    well_positions = ((1..12).to_a.product %w[A B C D E F G H]).map { |pair| "#{pair[1]}#{pair[0]}" }

    wells = well_positions.each_with_index.map do |position, index|
      well position: position, num_samples: samples_per_well, tag_set_id: index + 1
    end

    <<~GRAPHQL
      wells: [
        #{wells.join "\n"}
      ]
    GRAPHQL
  end

  PoolingScenario1 = TractionGraphQL::Client.parse <<~GRAPHQL
    mutation {
      createPlateWithOntSamples(
        input: {
          arguments: {
            barcode: "PLATE-PS01"
            #{wells samples_per_well: 1}
          }
        }
      ) { errors }
    }
  GRAPHQL

  PoolingScenario2 = TractionGraphQL::Client.parse <<~GRAPHQL
    mutation {
      createPlateWithOntSamples(
        input: {
          arguments: {
            barcode: "PLATE-PS02"
            #{wells samples_per_well: 1}
          }
        }
      ) { errors }
    }
  GRAPHQL

  PoolingScenario3 = TractionGraphQL::Client.parse <<~GRAPHQL
    mutation {
      createPlateWithOntSamples(
        input: {
          arguments: {
            barcode: "PLATE-PS03"
            #{wells samples_per_well: 96}
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
    submit_create_plate_query(CreatePlateQueries::PoolingScenario2, 'pooling scenario 2')
    submit_create_plate_query(CreatePlateQueries::PoolingScenario3, 'pooling scenario 3')
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

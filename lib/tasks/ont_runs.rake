# frozen_string_literal: true

# A set of GraphQL queries for creating ONT plates
module CreatePlateQueries
  def self.wells
    <<-GRAPHQL
      wells: [
        {
          position: "A1"
          samples: [
            { name: "Sample for A1" externalId: "A1ExtId" }
          ]
        }
        {
          position: "E7"
          samples: [
            { name: "Sample for E7" externalId: "E7ExtId" }
          ]
        }
        {
          position: "H12"
          samples: [
            { name: "Sample for H12" externalId: "H12ExtId" }
          ]
        }
      ]
    GRAPHQL
  end

  PoolingScenario1 = TractionGraphQL::Client.parse <<-GRAPHQL
    mutation {
      createPlateWithOntSamples(
        input: {
          arguments: {
            barcode: "PLATE-1234"
            #{wells}
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

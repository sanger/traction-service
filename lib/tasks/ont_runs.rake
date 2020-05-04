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
      ) {
        plate { id }
        errors
      }
    }
  GRAPHQL
end

namespace :ont_runs do
  task create: :environment do
    result = TractionGraphQL::Client.query CreatePlateQueries::PoolingScenario1
    puts result.to_h
  end

  task destroy: :environment do
    Sample.all.each do |sample|
      sample.destroy if sample.requests[0].requestable_type == 'Ont::Request'
    end
    [Ont::Request].each(&:delete_all)
    puts '-> ONT runs successfully deleted'
  end
end

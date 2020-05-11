# frozen_string_literal: true

require 'graphql/client'
require 'graphql/client/http'

# Prepare and manage the Traction GraphQL server
module TractionGraphQL
  # An HTTP class with no timeouts
  class NoTimeoutHTTP < GraphQL::Client::HTTP
    def connection
      http = super
      http.read_timeout = nil
      http
    end
  end

  # Configure GraphQL endpoint using the basic HTTP network adapter.
  RAILS_ROOT_URI = (ENV['RAILS_ROOT_URI'] || 'http://localhost:3000').chomp '/'
  HTTP = NoTimeoutHTTP.new("#{RAILS_ROOT_URI}/v2/")

  # Fetch latest schema on init, this will make a network request
  #   Schema = GraphQL::Client.load_schema(HTTP)
  #
  # Alternatively, to avoid the network request each time a rake task is performed,
  # you can dump this to a JSON file and load from disk
  # Dump:
  #   GraphQL::Client.dump_schema(TractionGraphQL::HTTP, TractionGraphQL::SchemaPath)
  # Load:
  #   Schema = GraphQL::Client.load_schema(SchemaPath)
  SchemaPath = File.join('lib', 'graphql_schema.json')
  Schema = GraphQL::Client.load_schema(SchemaPath)
  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)

  def self.dump_schema
    GraphQL::Client.dump_schema(HTTP, SchemaPath)
    true
  rescue Errno::ECONNREFUSED
    false
  end
end

# A set of GraphQL queries for creating ONT plates
module OntPlates
  CreatePlate = TractionGraphQL::Client.parse <<~GRAPHQL
    mutation($barcode: String!, $wells: [WellWithSampleInput!]!) {
      createPlateWithCovidSamples(
        input: {
          arguments: {
            barcode: $barcode
            wells: $wells
          }
        }
      ) { errors }
    }
  GRAPHQL

  # Methods to create variable objects for GraphQL
  class Variables
    def wells(sample_name:)
      well_positions = ((1..12).to_a.product %w[A B C D E F G H]).map do |pair|
        "#{pair[1]}#{pair[0]}"
      end
      tags = TagSet.find_by(name: 'OntWell96Samples').tags

      well_positions.each_with_index.map do |position, index|
        well position: position, sample_name: sample_name, tag_oligo: tags[index].oligo
      end
    end

    private

    def well(position:, sample_name:, tag_oligo:)
      {
        'position' => position,
        'sample' => {
          'name' => "Sample #{sample_name} in #{position}",
          'externalId' => "#{position}-ExtId",
          'tagOligo' => tag_oligo
        }
      }
    end
  end
end

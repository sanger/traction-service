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
    mutation($barcode: String!, $wells: [WellWithSamplesInput!]!) {
      createPlateWithOntSamples(
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
    def wells(samples_per_well:)
      well_positions = ((1..12).to_a.product %w[A B C D E F G H]).map do |pair|
        "#{pair[1]}#{pair[0]}"
      end

      well_positions.map do |position|
        well position: position, num_samples: samples_per_well
      end
    end

    private

    def sample(position:, sample_number:, tag_group_id_prefix:)
      padded_sample_number = format('%<number>03i', { number: sample_number })

      sample = {
        'name' => "Sample #{padded_sample_number} for #{position}",
        'externalId' => "#{position}-#{padded_sample_number}-ExtId"
      }

      unless tag_group_id_prefix.nil?
        padded_tag_number = format('%<number>02i', { number: sample_number })
        sample['tagGroupId'] = "#{tag_group_id_prefix}#{padded_tag_number}"
      end

      sample
    end

    def well(position:, num_samples:)
      {
        'position' => position,
        'samples' => (1..num_samples).map do |number|
          sample(
            position: position,
            sample_number: number,
            tag_group_id_prefix: num_samples == 96 ? 'ont_96_tag_' : nil
          )
        end
      }
    end
  end
end

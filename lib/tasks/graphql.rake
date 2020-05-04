# frozen_string_literal: true

require 'graphql/client'
require 'graphql/client/http'

# Prepare and manage the Traction GraphQL server
module TractionGraphQL
  # Configure GraphQL endpoint using the basic HTTP network adapter.
  RAILS_ROOT_URI = (ENV['RAILS_ROOT_URI'] || 'http://localhost:3000').chomp '/'
  HTTP = GraphQL::Client::HTTP.new("#{RAILS_ROOT_URI}/v2/")

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

  # Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)

  def self.dump_schema
    GraphQL::Client.dump_schema(HTTP, SchemaPath)
    true
  rescue Errno::ECONNREFUSED
    false
  end
end

namespace :graphql do
  task dump_schema: :environment do
    puts '-> Dumping GraphQL schema'
    gql = TractionGraphQL.new
    if gql.dump_schema
      puts '-> GraphQL schema dumped successfully'
    else
      puts "-> Failed to dump the GraphQL schema from Rails server at #{TractionGraphQL::RAILS_ROOT_URI}"
      puts '   Use the RAILS_ROOT_URI environment variable to specify a different URI'
    end
  end
end

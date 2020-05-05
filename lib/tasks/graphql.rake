# frozen_string_literal: true

require_relative '../traction_graphql'

namespace :graphql do
  task dump_schema: :environment do
    puts '-> Dumping GraphQL schema'
    if TractionGraphQL.dump_schema
      puts '-> GraphQL schema dumped successfully'
    else
      puts "-> Failed to dump the GraphQL schema from Rails server at #{TractionGraphQL::RAILS_ROOT_URI}"
      puts '   Use the RAILS_ROOT_URI environment variable to specify a different URI'
    end
  end
end

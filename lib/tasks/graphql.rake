# frozen_string_literal: true

require_relative '../traction_graphql'
require 'graphql/rake_task'
require 'graphql-docs'

options = {
  schema_name: 'TractionServiceSchema',
  directory: 'lib',
  idl_outfile: 'graphql_schema.graphql',
  json_outfile: 'graphql_schema.json'
}

GraphQL::RakeTask.new(options)

namespace :graphql do
  namespace :docs do
    task generate: :environment do
      puts '-> Generating GraphQL documentation from the saved schema.'
      puts '   If the schema is out of date, run rake task graphql:schema:dump first.'
      GraphQLDocs.build(filename: File.join(options[:directory], options[:idl_outfile]),
                        delete_output: true,
                        base_url: '/v2/docs',
                        output_dir: './app/views/graphql')
      puts '-> Finished generating GraphQL documentation.  View it at served path v2/docs/.'
    end
  end
end

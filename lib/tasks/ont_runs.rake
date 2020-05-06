# frozen_string_literal: true

require 'benchmark'

require_relative '../traction_graphql'

namespace :ont_runs do
  def show_errors(error_lines)
    error_lines.each { |line| puts line }
    exit
  end

  def report_time(benchmark)
    puts
    puts 'Time taken:'
    puts benchmark.real
    puts
  end

  def submit_create_plate_query(description:, barcode:, wells:)
    puts "-> Creating a plate for #{description}"
    result = TractionGraphQL::Client.query(OntPlates::CreatePlate, variables: { barcode: barcode, wells: wells })

    errors_array = result.original_hash['data']['createPlateWithOntSamples']['errors']
    if errors_array.any?
      show_errors ["-> Failed to create plate for #{description}: #{errors_array}"]
    end

    puts "-> Succesfully created a plate for #{description}"
  rescue Errno::ECONNREFUSED
    show_errors ["-> Failed to connect to the Rails server at #{TractionGraphQL::RAILS_ROOT_URI}",
                 '   Use the RAILS_ROOT_URI environment variable to specify a different URI']
  end

  task create: %i[environment create_scenario_1_plate create_scenario_2_plate create_scenario_3_plate] do
    puts '-> Creating ONT runs using GraphQL'
    puts '   Note these could take a few minutes to complete'

    # TODO: Create ONT runs when the endpoints are available

    puts '-> Successfully created all ONT runs'
  end

  task create_scenario_1_plate: :environment do
    variables = OntPlates::Variables.new

    time = Benchmark.measure do
      submit_create_plate_query(description: 'pooling scenario 1', barcode: 'PLATE-PS01', wells: variables.wells(samples_per_well: 1))
    end

    report_time(time)
  end

  task create_scenario_2_plate: :environment do
    variables = OntPlates::Variables.new

    time = Benchmark.measure do
      submit_create_plate_query(description: 'pooling scenario 2', barcode: 'PLATE-PS02', wells: variables.wells(samples_per_well: 1))
    end

    report_time(time)
  end

  task create_scenario_3_plate: :environment do
    variables = OntPlates::Variables.new

    time = Benchmark.measure do
      submit_create_plate_query(description: 'pooling scenario 3', barcode: 'PLATE-PS03', wells: variables.wells(samples_per_well: 96))
    end

    report_time(time)
  end

  task destroy: :environment do
    # TODO: This needs to be made to work correctly for ONT
    Sample.all.each do |sample|
      sample.destroy if sample.requests[0].requestable_type == 'Ont::Request'
    end
    [Ont::Request].each(&:delete_all)
    puts '-> ONT runs successfully deleted'
  end
end

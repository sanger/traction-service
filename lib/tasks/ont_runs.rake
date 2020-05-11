# frozen_string_literal: true

require_relative '../traction_graphql'

namespace :ont_runs do
  task create: :environment do
    puts '-> Creating ONT runs using GraphQL'

    create_plates(count: 5)
    # TODO: Create libraries from plates
    # TODO: Create ONT runs when the endpoints are available

    puts
    puts '-> Successfully created all ONT runs'
  end

  task destroy: :environment do
    Plate.all.each do |plate|
      plate.destroy if plate.barcode.start_with? 'DEMO-PLATE-'
    end
    [Ont::Request].each(&:delete_all)
    puts '-> ONT runs successfully deleted'
  end
end

### Helper Methods ###

def show_errors(error_lines)
  error_lines.each { |line| puts line }
  exit
end

def submit_create_plate_query(plate_no:, barcode:, wells:)
  puts "-> Creating plate number #{plate_no}"
  result = TractionGraphQL::Client.query(OntPlates::CreatePlate, variables: { barcode: barcode, wells: wells })

  errors_array = result.original_hash['data']['createPlateWithCovidSamples']['errors']
  show_errors ["-> Failed to create plate number #{plate_no}: #{errors_array}"] if errors_array.any?

  puts "-> Succesfully created plate number #{plate_no}"
rescue Errno::ECONNREFUSED
  show_errors ["-> Failed to connect to the Rails server at #{TractionGraphQL::RAILS_ROOT_URI}",
               '   Use the RAILS_ROOT_URI environment variable to specify a different URI']
end

def create_plates(count:)
  puts
  puts "-> Creating #{count} ONT plates"
  variables = OntPlates::Variables.new

  count.times do |i|
    plate_no = i + 1
    submit_create_plate_query(plate_no: plate_no,
                              barcode: "DEMO-PLATE-#{plate_no}",
                              wells: variables.wells(sample_name: "for Demo Plate #{plate_no}"))
  end

  puts '-> Successfully created ONT plates'
end

# frozen_string_literal: true

require_relative '../traction_graphql'

namespace :ont_runs do
  task create: :environment do
    puts '-> Creating ONT runs using GraphQL'

    create_plates(count: 5)
    create_libraries(count: 5)
    create_runs(library_count: 5)

    puts
    puts '-> Successfully created all ONT runs'
  end

  task destroy: :environment do
    Plate.all.each do |plate|
      plate.destroy if plate.barcode.start_with? 'DEMO-PLATE-'
    end
    [Ont::Request, Ont::Library, Ont::Flowcell, Ont::Run].each(&:delete_all)
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
  constants_accessor = Pipelines::ConstantsAccessor.new(Pipelines.ont.covid)

  count.times do |i|
    plate_no = i + 1
    submit_create_plate_query(plate_no: plate_no,
                              barcode: "DEMO-PLATE-#{plate_no}",
                              wells: variables.wells(sample_name: "for Demo Plate #{plate_no}",
                                                     constants_accessor: constants_accessor))
  end

  puts '-> Successfully created ONT plates'
end

def submit_create_library_query(plate_barcode:)
  puts "-> Creating library for plate with barcode #{plate_barcode}"
  result = TractionGraphQL::Client.query(OntLibraries::CreateLibraries, variables: { plate_barcode: plate_barcode })

  errors_array = result.original_hash['data']['createCovidLibraries']['errors']
  if errors_array.any?
    show_errors ["-> Failed to create library for plate with barcode #{plate_barcode}: #{errors_array}"]
  end

  puts "-> Succesfully created library for plate with barcode number #{plate_barcode}"
rescue Errno::ECONNREFUSED
  show_errors ["-> Failed to connect to the Rails server at #{TractionGraphQL::RAILS_ROOT_URI}",
               '   Use the RAILS_ROOT_URI environment variable to specify a different URI']
end

def create_libraries(count:)
  puts
  puts "-> Creating #{count} ONT libraries from plates"

  count.times do |i|
    submit_create_library_query(plate_barcode: "DEMO-PLATE-#{i + 1}")
  end

  puts '-> Successfully created ONT libraries'
end

def submit_create_run_query(variables:, library_names:)
  flowcells = variables.flowcells(library_names: library_names)
  joined_library_names = library_names.join(', ')
  puts "-> Creating run for libraries with names: #{joined_library_names}"
  result = TractionGraphQL::Client.query(OntRuns::CreateRun, variables: { flowcells: flowcells })

  errors_array = result.original_hash['data']['createCovidRun']['errors']
  if errors_array.any?
    show_errors ["-> Failed to create run for libraries with names #{joined_library_names}: #{errors_array}"]
  end

  puts "-> Succesfully created run for libraries with names: #{joined_library_names}"
rescue Errno::ECONNREFUSED
  show_errors ["-> Failed to connect to the Rails server at #{TractionGraphQL::RAILS_ROOT_URI}",
               '   Use the RAILS_ROOT_URI environment variable to specify a different URI']
end

def create_runs(library_count:)
  puts
  puts "-> Creating 2 ONT runs from #{library_count} libraries"

  variables = OntRuns::Variables.new
  library_names = library_count.times.map { |i| "DEMO-PLATE-#{i + 1}-1" }
  num_run_one = (library_count / 2.0).ceil
  num_run_two = library_count - num_run_one

  submit_create_run_query(variables: variables, library_names: library_names.first(num_run_one))
  if num_run_two > 0
    submit_create_run_query(variables: variables, library_names: library_names.last(num_run_two))
  end

  puts '-> Successfully created ONT runs'
end

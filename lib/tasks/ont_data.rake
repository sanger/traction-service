# frozen_string_literal: true

require 'securerandom'

namespace :ont_data do
  desc 'Populate the database with ont plates and tubes'
  task create: [:environment] do
    require_relative 'reception_generator'

    number_of_plates = ENV.fetch('PLATES', 2).to_i
    number_of_tubes = ENV.fetch('TUBES', 2).to_i
    wells_per_plate = ENV.fetch('WELLS_PER_PLATE', 95).to_i

    ReceptionGenerator.new(
      number_of_plates:,
      number_of_tubes:,
      wells_per_plate:,
      pipeline: :ont
    ).construct_resources!

    puts "-> Created requests for #{number_of_plates} plates and #{number_of_tubes} tubes"
  end
end

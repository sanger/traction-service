# frozen_string_literal: true

namespace :ont_instruments do
  desc 'Create ONT instruments'
  task create: :environment do
    [
      { name: 'M1', instrument_type: 'MinION', max_number_of_flowcells: 1 },
      { name: 'G1', instrument_type: 'GridION', max_number_of_flowcells: 5 },
      { name: 'P1', instrument_type: 'PromethION', max_number_of_flowcells: 24 }
    ].each do |options|
      Ont::Instrument.create_with(options).find_or_create_by!(name: options[:name])
    end
    puts '-> Instrument names added'
  end
end

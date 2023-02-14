# frozen_string_literal: true

namespace :ont_instruments do
  desc 'Create ONT instruments'
  task create: :environment do
    # Load ONT Instruments configuration.
    config_name = 'ont_instruments.yml'
    config_path = Rails.root.join('config', config_name)
    config = YAML.load_file(config_path, aliases: true)[Rails.env]

    # Create ONT Instruments
    instruments = config['instruments']
    instruments.each do |_key, options|
      Ont::Instrument.create_with(options).find_or_create_by!(name: options['name'])
    end

    puts '-> ONT Instruments successfully created'
  end
end

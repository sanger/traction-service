namespace :ont_instruments do
    desc 'Create ONT instruments'
    task create: :environment do
      [
        { name: 'MinIon', max_number: 1 },
        { name: 'GridIon', max_number: 5 },
        { name: 'PromethIon', max_number: 24 },
      ].each do |options|
        Ont::Instrument.create_with(options).find_or_create_by!(name: options[:name])
      end
      puts '-> Instrument names added'
    end
  end
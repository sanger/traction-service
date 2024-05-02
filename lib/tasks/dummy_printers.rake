# frozen_string_literal: true

namespace :dummy_printers do
  desc 'Create dummy printers'
  task create: :environment do
    puts '-> Creating dummy printers'
    [
      { name: 'Tube Printer', labware_type: 'tube' },
      { name: '96-Well Plate Printer', labware_type: 'plate96' },
      { name: '384-Well Plate Printer', labware_type: 'plate384' },
      { name: 'Deactivated Printer', labware_type: 'tube', deactivated_at: Time.current }
    ].each do |options|
      Printer.create_with(options).find_or_create_by!(name: options[:name])
      puts "  -> #{options[:name]}"
    end
    puts '-> Dummy printers created'
  end
end

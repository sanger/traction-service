# frozen_string_literal: true

namespace :printers do
  task create: :environment do
    [
      { name: 'g216bc', labware_type: 'tube' },
      { name: 'h105bc', labware_type: 'tube' },
      { name: 'ssrtubebc-sq1', labware_type: 'tube' },
      { name: 'aa309bc1', labware_type: 'tube' },
      { name: 'g311bc1', labware_type: 'tube' },
      { name: 'aa309bc3', labware_type: 'tube' }
    ].each do |options|
      Printer.create_with(options).find_or_create_by!(name: options[:name])
    end
    puts '-> Printers succesfully updated'
  end

  task destroy: :environment do
    Printer.delete_all
    puts '-> Printers succesfully deleted'
  end
end

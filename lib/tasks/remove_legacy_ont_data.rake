# frozen_string_literal: true

# Used to remove old ONT data causing issues in production (06/03/2023)

namespace :legacy_ont_data do
  desc 'Remove legacy ONT data'
  task remove: :environment do
    # Deleting records older than a year is a bit crude but in this case it works fine as we know the timeframe
    Plate.where("plates.created_at < '#{1.year.ago}'").by_pipeline(:ont).each do |plate|
      puts "-> Deleting plate #{plate.barcode}"
      # We use delete instead of destroy as we want to be careful about potentially mixed child records
      plate.wells.each do |well|
        well.container_materials.delete_all
        well.delete
      end

      plate.delete
    end

    puts '-> Successfully removed ONT legacy data'
  end
end

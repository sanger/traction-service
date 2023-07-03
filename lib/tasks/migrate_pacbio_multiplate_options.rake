# frozen_string_literal: true

# In this data migration, we are adding the sequencing_kit_box_barcode and plate_number
namespace :pacbio_plate do
  task migrate_multiplate_options: :environment do
    plates = Pacbio::Plate.all
    plates.each do |plate|
      plate.update!(sequencing_kit_box_barcode: plate.run.sequencing_kit_box_barcode, plate_number: 1)
    end

    puts "-> #{plates.length} instances of pacbio well updated."
  end
end

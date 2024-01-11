# frozen_string_literal: true

namespace :pacbio_aliquot_data do
  desc 'A series of rake tasks to migrate existing pacbio data to the new aliquot data model'
  task migrate_pool_data: :environment do
    puts '-> Creating primary aliquots for all pools'
    # Create primary aliquots for all pools
    Pacbio::Pool.find_each do |pool|
      # Skip if aliquots already exist (shouldn't happen but just in case)
      next if pool.aliquots.any?

      # Create primary aliquot with same attributes as pool
      Aliquot.create!(
        volume: pool.volume,
        concentration: pool.concentration,
        template_prep_kit_box_barcode: pool.template_prep_kit_box_barcode,
        insert_size: pool.insert_size,
        source: pool,
        aliquot_type: :primary,
        state: :created
      )

      # For each instance this pool is used in a well, create a derived aliquot
      pool.wells.each do |well|
        # To be safe we assume the volumes are the same for existing pools
        derived_aliquot.create!(
          volume: pool.volume,
          concentration: pool.concentration,
          template_prep_kit_box_barcode: pool.template_prep_kit_box_barcode,
          insert_size: pool.insert_size,
          source: pool,
          well:,
          aliquot_type: :derived,
          state: :created
        )
      end
    end
  end
end

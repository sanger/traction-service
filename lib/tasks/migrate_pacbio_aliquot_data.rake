# frozen_string_literal: true

namespace :pacbio_aliquot_data do
  desc 'A series of rake tasks to migrate existing pacbio data to the new aliquot data model'
  task migrate_all_data: :environment do
    Rake::Task['pacbio_aliquot_data:migrate_library_data'].invoke
    Rake::Task['pacbio_aliquot_data:migrate_pool_data'].invoke
  end

  task migrate_library_data: :environment do
    puts '-> Creating primary aliquots for all libraries'
    # Create primary aliquots for all libraries
    Pacbio::Library.find_each do |library|
      # Skip if aliquots already exist (shouldn't happen but just in case)
      next if library.aliquots.any?

      # Create primary aliquot with same attributes as library
      Aliquot.create!(
        volume: library.volume,
        concentration: library.concentration,
        template_prep_kit_box_barcode: library.template_prep_kit_box_barcode,
        insert_size: library.insert_size,
        source: library,
        aliquot_type: :primary,
        state: :created
      )

      # If the library has a pool (it should), create a derived aliquot
      if library.pool.present?
        # To be safe we assume the volumes are the same for existing libraries
        Aliquot.create!(
          volume: library.volume,
          concentration: library.concentration,
          template_prep_kit_box_barcode: library.template_prep_kit_box_barcode,
          insert_size: library.insert_size,
          source: library,
          aliquot_type: :derived,
          state: :created
        )
      end
    end
  end

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
        Aliquot.create!(
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

  # This task is used to revert the changes made by the above tasks
  # This can be more sophisticated as we add more elements to the migration
  task revert_all_data: :environment do
    puts '-> Deleting all aliquots'
    # Delete all primary and derived aliquots
    Aliquot.destroy_all
  end
end

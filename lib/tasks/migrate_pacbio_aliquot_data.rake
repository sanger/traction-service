# frozen_string_literal: true

namespace :pacbio_aliquot_data do
  desc 'A series of rake tasks to migrate existing pacbio data to the new aliquot data model'
  task migrate_request_data: :environment do
    puts '-> Creating primary aliquots for all requests'
    # Create aliquots for all requests
    Pacbio::Request.find_each do |request|
      # Skip if primary aliquot already exists (shouldn't happen but just in case)
      next if request.primary_aliquot.present?

      # Create aliquot with same attributes as request
      Aliquot.create!(
        volume: nil,
        concentration: nil,
        template_prep_kit_box_barcode: nil,
        insert_size: nil,
        source: request,
        aliquot_type: :primary,
        state: :created
      )
    end
  end

  task revert_request_data: :environment do
    puts '-> Deleting all request primary aliquots'
    # Delete all primary and derived aliquots
    Pacbio::Request.find_each do |request|
      request.primary_aliquot.delete if request.primary_aliquot.present?
    end
  end

  task migrate_library_data: :environment do
    puts '-> Creating primary aliquots for all libraries and derived aliquots for all requests used in libraries'

    # Clear well libraries table as we will be re-adding them and don't want duplicates or validation errors
    Pacbio::WellLibrary.delete_all

    Pacbio::Pool.find_each do |pool|
      next unless pool.libraries.count == 1

      library = pool.libraries.first
      new_lib = library.dup
      # Set the libraries tube to the pools tube
      new_lib.tube = pool.tube
      new_lib.pool = nil
      new_lib.created_at = pool.created_at
      # Setup the library defaults in case they don't exist
      new_lib.volume = new_lib.volume || 0
      new_lib.concentration = new_lib.concentration || 0
      new_lib.template_prep_kit_box_barcode = new_lib.template_prep_kit_box_barcode || '033000000000000000000'
      # Create the libraries primary aliquot
      # A used_by aliquot is automatically created
      new_lib.primary_aliquot = Aliquot.create(
        volume: new_lib.volume,
        concentration: new_lib.concentration,
        template_prep_kit_box_barcode: new_lib.template_prep_kit_box_barcode,
        insert_size: new_lib.insert_size,
        source: new_lib,
        tag: new_lib.tag,
        aliquot_type: :primary,
        state: :created
      )

      new_lib.save

      # Here we will need to attach the new library to the wells the pool was attached to
      pool.wells.each do |well|
        well.libraries << new_lib
        well.save
      end

      begin
        pool.destroy!
      rescue ActiveRecord::RecordNotDestroyed => e
        puts "errors that prevented pool id:#{pool.id} destruction: #{e.record.errors.full_messages}"
      end
    end
  end

  task migrate_pool_data: :environment do
    puts '-> Creating primary aliquots for all pools and derived aliquots for all requests used in pools'
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

      # For each library this pool has, create a derived aliquot from the library request
      pool.libraries.each do |library|
        Aliquot.create!(
          volume: pool.volume,
          concentration: pool.concentration,
          template_prep_kit_box_barcode: pool.template_prep_kit_box_barcode,
          insert_size: pool.insert_size,
          source: library.request,
          aliquot_type: :derived,
          used_by: pool,
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

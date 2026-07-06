# frozen_string_literal: true

# This task merges the deprecated Pacbio_96_barcode_plate_v3 tag set with
# SMRTbell_Barcoded_Adapter_Plates_ABCD.
#
# Story: Y26-179
# Pacbio_96_barcode_plate_v3 is a heavily used tag set that is a subset of the
# new SMRTbell_Barcoded_Adapter_Plates_ABCD tag set. Users want to use samples from
# the Pacbio_96_barcode_plate_v3 tag set with samples using the new
# SMRTbell_Barcoded_Adapter_Plates_ABCD tag set. They also want the Pacbio_96_barcode_plate_v3
# tag set to be deprecated and removed from the system. Currently Traction only
# supports one tag set per pool so users cannot use both tag sets in the same pool.
# This task will merge the two tag sets so that users can use samples from both tag sets
# in the same pool
#
# Due to the heavy historical usage of the Pacbio_96_barcode_plate_v3 tag set it is not sensible
# to migrate the data using the tags across to use the equivalent
# SMRTbell_Barcoded_Adapter_Plates_ABCD tags. This would cause inconsistent historical data and
# would be a lot of work to migrate. Particularly the extensive records in the MLWH (12000+).
#
# Solution:
# - Swap the Pacbio_96_barcode_plate_v3 tags and their equivalent
#   SMRTbell_Barcoded_Adapter_Plates_ABCD tags.
#   - Note: this retains the tag_ids in the database and so historical data remains consistent.
# - Migrate data using the new Pacbio_96_barcode_plate_v3 tags
#   (old SMRTbell_Barcoded_Adapter_Plates_ABCD tags) to use the
#   equivalent SMRTbell_Barcoded_Adapter_Plates_ABCD tags.
#   - Note: Small migration ~300 records to update the libraries and request pool used aliquots to
#     use the new tags. Tag group_id/oligo will remain the same so this is a simple update of the
#     tag_id in the database.
# - Deactivate the old Pacbio_96_barcode_plate_v3 tag set.
#
namespace :single_use do # rubocop:disable Metrics/BlockLength
  # Check that the required tag sets exist and return them
  def check_tag_sets_exist
    p96v3_tag_set = TagSet.find_by(name: 'Pacbio_96_barcode_plate_v3')
    smrtbell_tag_set = TagSet.find_by(name: 'SMRTbell_Barcoded_Adapter_Plates_ABCD')

    if p96v3_tag_set.nil? || smrtbell_tag_set.nil?
      raise 'One or both tag sets not found. Please check the tag set names.'
    end

    puts '-> Validated tag sets exist'
    [p96v3_tag_set, smrtbell_tag_set]
  end

  # Swap the overlapping tags between the two tag sets.
  # A temporary tag set is created to avoid unique-index collisions while swapping.
  # The temporary tag set is destroyed after the swap is complete.
  def swap_tags_between_tag_sets(p96v3_tag_set, smrtbell_tag_set) # rubocop:disable Metrics/MethodLength
    # Get the tags to swap
    p96v3_tags = p96v3_tag_set.tags
    p96v3_smrtbell_tags = smrtbell_tag_set.tags.where(group_id: p96v3_tags.pluck(:group_id))

    # Create a temporary tag set to avoid unique-index collisions while swapping.
    temp_tag_set = TagSet.create!(
      name: "Pacbio_SMRTbell_merge_temp_#{SecureRandom.uuid}",
      pipeline: p96v3_tag_set.pipeline,
      sample_sheet_behaviour: p96v3_tag_set.sample_sheet_behaviour,
      active: false
    )

    # Move p96v3 tags out of the way first.
    p96v3_tags.each { |tag| tag.update!(tag_set_id: temp_tag_set.id) }
    # Move smrtbell tags to p96v3.
    p96v3_smrtbell_tags.each { |tag| tag.update!(tag_set_id: p96v3_tag_set.id) }
    # Move original p96v3 tags into smrtbell.
    temp_tag_set.tags.find_each { |tag| tag.update!(tag_set_id: smrtbell_tag_set.id) }

    # Remove the temporary tag set after the swap is complete
    temp_tag_set.destroy!
    puts '-> Swapped overlapping tags'
  end

  # Migrate libraries using the old Pacbio_96_barcode_plate_v3 tags to use the equivalent
  # SMRTbell_Barcoded_Adapter_Plates_ABCD tags.
  def migrate_libraries(p96v3_tag_set, smrtbell_tag_set) # rubocop:disable Metrics/MethodLength
    Pacbio::Library.joins(:tag).where(
      tags: { tag_set_id: p96v3_tag_set.id }
    ).find_each do |library|
      # Find the corresponding tag in the SMRTbell_Barcoded_Adapter_Plates_ABCD tag set
      new_tag = smrtbell_tag_set.tags.find_by(group_id: library.tag.group_id)
      if new_tag.nil?
        puts "No tag found in SMRTbell_Barcoded_Adapter_Plates_ABCD for library #{library.id}"
        raise ActiveRecord::Rollback
      end

      # Update the library to use the new tag
      library.update!(tag: new_tag)
      library.primary_aliquot.update!(tag: new_tag)
      library.used_aliquots.each { |aliquot| aliquot.update!(tag: new_tag) }
    end
    puts '-> Migrated libraries'
  end

  # Migrate pool used aliquots using the old Pacbio_96_barcode_plate_v3 tags to use the equivalent
  # SMRTbell_Barcoded_Adapter_Plates_ABCD tags.
  # This is necessary because the pool used aliquots are not directly associated with a library so
  # could have differing tags and could come from Requests or Libraries
  def migrate_pool_aliquots(p96v3_tag_set, smrtbell_tag_set)
    # Update the pool used aliquots to use the new tags
    Aliquot.where(aliquot_type: :derived, used_by_type: 'Pacbio::Pool',
                  source_type: ['Pacbio::Request', 'Pacbio::Library'],
                  tag_id: p96v3_tag_set.tags.pluck(:id).to_a).find_each do |aliquot|
      # Find the corresponding tag in the SMRTbell_Barcoded_Adapter_Plates_ABCD tag set
      new_tag = smrtbell_tag_set.tags.find_by(group_id: aliquot.tag.group_id)
      if new_tag.nil?
        puts "No tag found in SMRTbell_Barcoded_Adapter_Plates_ABCD for aliquot #{aliquot.id}"
        raise ActiveRecord::Rollback
      end

      # Update the aliquot to use the new tag
      aliquot.update!(tag: new_tag)
    end
    puts '-> Migrated pool used aliquots'
  end

  desc 'Merge Pacbio_96_barcode_plate_v3 tag set with SMRTbell_Barcoded_Adapter_Plates_ABCD'
  task merge_pacbio_smrtbell_tag_sets: :environment do
    # Find the tag sets by name and raise an error if they do not exist
    p96v3_tag_set, smrtbell_tag_set = check_tag_sets_exist

    # Perform the swap and migration in a transaction to ensure atomicity
    ActiveRecord::Base.transaction do
      # Swap the tags in the two tag sets
      swap_tags_between_tag_sets(p96v3_tag_set, smrtbell_tag_set)

      # Ensure the tag sets are reloaded to reflect the swaps
      p96v3_tag_set.reload
      smrtbell_tag_set.reload

      # Migrate affected libraries
      migrate_libraries(p96v3_tag_set, smrtbell_tag_set)

      # Migrate affected pool used aliquots
      migrate_pool_aliquots(p96v3_tag_set, smrtbell_tag_set)

      # Deactivate the old Pacbio_96_barcode_plate_v3 tag set
      p96v3_tag_set.update!(active: false)
      puts '-> Deactivated Pacbio_96_barcode_plate_v3 tag set'

      # Output a message indicating the successful completion of the task
      puts 'Successfully merged Pacbio_96_barcode_plate_v3 tag set with
            SMRTbell_Barcoded_Adapter_Plates_ABCD'
    end
  end
end

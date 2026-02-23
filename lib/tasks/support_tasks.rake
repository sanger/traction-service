# frozen_string_literal: true

namespace :support_tasks do
  # Example usage 'bundle exec rails "support_tasks:pacbio_library_sample_swap[5,4]"'
  desc 'Swap the samples of two libraries and push all related data to the warehouse'
  task :pacbio_library_sample_swap, %i[library1_id library2_id] => :environment do |_t, args|
    library1_id = args[:library1_id]
    library2_id = args[:library2_id]

    library1 = Pacbio::Library.find_by(id: library1_id)
    library2 = Pacbio::Library.find_by(id: library2_id)

    unless library1 && library2
      puts "Warning: Could not find library with id #{library1_id}" unless library1
      puts "Warning: Could not find library with id #{library2_id}" unless library2
      exit 0
    end

    ActiveRecord::Base.transaction do
      request1 = library1.request
      request2 = library2.request

      # Annoyingly request is linked to the library through request_id and used/derived_aliquots so we need to update both
      library1.request = request2
      # We make the assumption here that there is only one used aliquot per library
      library1.used_aliquots.first.update!(source_id: request2.id)
      library1.save!

      library2.request = request1
      library2.used_aliquots.first.update!(source_id: request1.id)
      library2.save!

      # Update the updated_at attribute for all primary and derived aliquots of both libraries
      # This ensures that any messages published to the warehouse for these aliquots will have the updated timestamp
      # so are correctly processed.
      # If we don't do this the warehouse will ignore the updates as the aliquot sample_name attribute change does not occur
      # directly on the aliquot so the updated_at timestamp does not change and the warehouse assumes there is no change to process.
      #
      # .aliquots is all aliquots where the library is the source, so includes both primary and derived aliquots
      library1.aliquots.each(&:touch)
      library2.aliquots.each(&:touch)
    end

    puts "-> Swapped samples of libraries #{library1_id} and #{library2_id}"

    sequencing_runs = []
    # Ensure all related data is published to the warehouse
    [library1, library2].each do |library|
      # We need to publish the primary aliquot and all used aliquots for the library as the sample name and source has changed
      Emq::Publisher.publish([library.primary_aliquot, *library.used_aliquots],
                             Pipelines.pacbio, 'volume_tracking')

      # We also need to republish the messages for any runs that the library is in as the sample has changed
      sequencing_runs += library.sequencing_runs

      # We also need to republish the messages for any pools that the library is in as the sample has changed
      library.derived_aliquots.each do |aliquot|
        next unless aliquot.used_by_type == 'Pacbio::Pool'

        pool = aliquot.used_by
        sequencing_runs += pool.sequencing_runs
      end
    end

    # Publish sequencing runs together at the end to ensure they are only published once
    sequencing_runs.uniq.each do |run|
      puts "-> Republishing run data and volume tracking messages for run #{run.name}"
      Messages.publish(run, Pipelines.pacbio.message)
      Emq::Publisher.publish(run.aliquots_to_publish_on_run, Pipelines.pacbio, 'volume_tracking')
    end
  end
end

# frozen_string_literal: true

namespace :pool_and_library_aliquots do
  #  A rake task to be run to push all pool and library aliquots data to the warehouse for volume tracking
  desc 'Push all pool and library aliquots data to the warehouse for volume tracking'

  task push_data_to_warehouse: :environment do
    puts '-> Pushing all pool and library aliquots data to the warehouse for volume tracking'

    begin
      # Following are the contexts where aliquots are created. We need to push, the primary aliquots created for a pool and library (1,2)
      # and the derived aliquots of a pool and library (directly or indirectly through a pool) used in a run  to the warehouse
      # 1. When a library or pool is created, primary aliquot is created
      # 2. When a library is used in pool or run, derived aliquot is created
      # 3. When a pool is used in run, derived aliquot is created
      # 4. When a request is imported into the reception, a primary aliquot is created
      # 5. When a request is used in a pool or library, derived aliquot is created

      aliquots = []
      # Filter all aliquots that are not from a Pacbio::Request or not from a Pacbio::Library which has used by a Pacbio::Pool
      filtered_aliquots = Aliquot.where(used_by_type: 'Pacbio::Well')
                                 .or(Aliquot.where(source_type: 'Pacbio::Pool', aliquot_type: 'primary'))
                                 .or(Aliquot.where(source_type: 'Pacbio::Library', aliquot_type: 'primary'))
                                 .or(Aliquot.where(source_type: 'Pacbio::Request', used_by_type: 'Pacbio::Library', aliquot_type: 'derived'))
                                 .to_a
      aliquots.concat(filtered_aliquots)

      # Find aliquots from a Pacbio::Pool used by a Pacbio::Well and add their source's used aliquots if from a Pacbio::Library
      filtered_aliquots.select { |aliquot| aliquot.source_type == 'Pacbio::Pool' && aliquot.used_by_type == 'Pacbio::Well' }.each do |aliquot|
        library_aliquots_in_pool = aliquot.source.used_aliquots.select { |used_aliquot| used_aliquot.source_type == 'Pacbio::Library' }
        aliquots.concat(library_aliquots_in_pool)
      end
      Emq::Publisher.publish(aliquots, Pipelines.pacbio, 'volume_tracking')

      puts '-> Successfully pushed all pool and library aliquots data to the warehouse'
    rescue StandardError => e
      Rails.logger.error("Failed to publish message: #{e.message}")
      puts "-> Failed to push aliquots data to the warehouse: #{e.message}"
    end
  end
end

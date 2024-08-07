# frozen_string_literal: true

namespace :pool_and_library_aliquots do
  #  A rake task to be run to push all pool and library aliquots data to the warehouse for volume tracking
  desc 'Push all pool and library aliquots data to the warehouse for volume tracking'

  task push_data_to_warehouse: :environment do
    puts '-> Pushing all pool and library aliquots data to the warehouse for volume tracking'

    begin
      # Following are the contexts where aliquots are created, out of which only the aliquots from libraries and pools (1,2,3) are used for volume tracking
      # 1. When a library or pool is created, primary aliquot is created
      # 2. When a library is used in pool or run, derived aliquot is created
      # 3. When a pool is used in run, derived aliquot is created
      # 4. When a request is imported into the reception, a primary aliquot is created
      # 5. When a request is used in a pool or library, derived aliquot is created

      # Filter all aliquots that are not from a Pacbio::Request
      aliquots = Aliquot.where.not(source_type: 'Pacbio::Request')
      Emq::Publisher.publish(aliquots, Pipelines.pacbio, 'volume_tracking')

      puts '-> Successfully pushed all pool and library aliquots data to the warehouse'
    rescue StandardError => e
      Rails.logger.error("Failed to publish message: #{e.message}")
      puts "-> Failed to push aliquots data to the warehouse: #{e.message}"
    end
  end
end

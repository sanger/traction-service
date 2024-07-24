# frozen_string_literal: true

# Rake tasks associated with volume tracking
namespace :volume_tracking do
  # A rake task to be run once in production to clear the volume of all well aliquots
  # As we have assumed we should take the full volume of each library / pool used in a well
  # But this is arbitrary and causes volume_check failures
  desc 'Clear the volume and concentration of all well aliquots'
  task clear_well_aliquot_volume: :environment do
    puts '-> Clearing volume of all well aliquots'

    ActiveRecord::Base.transaction do
      # If an aliquot is used by a well set its volume and conc to 0
      Aliquot.where(used_by_type: 'Pacbio::Well').find_each do |aliquot|
        aliquot.update!(volume: 0, concentration: 0)
      end
    end
  end
end

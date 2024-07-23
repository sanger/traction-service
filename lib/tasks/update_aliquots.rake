# frozen_string_literal: true

namespace :update_aliquots do
  # A rake task to be run once in production to clear the volume of all well aliquots
  # As we have assumed we should take the full volume of each library / pool used in a well
  # But this is arbitrary and causes volume_check failures
  desc 'Update aliquots with UUID'

  task update_uuid: :environment do
    puts '-> Updating aliquots with UUID'

    ActiveRecord::Base.transaction do
      # If an aliquot does not have a UUID set it
      Aliquot.where(uuid: nil).find_each do |aliquot|
        aliquot.update!(uuid: SecureRandom.uuid.to_s)
      end
    end
  end
end

# frozen_string_literal: true

namespace :aliquots do
  #  A rake task to be run to add UUIDs to all aliquots that do not have one
  desc 'Update aliquots with UUID'

  task add_missing_uuids: :environment do
    puts '-> Updating aliquots with UUID'

    ActiveRecord::Base.transaction do
      # If an aliquot does not have a UUID set it
      Aliquot.where(uuid: nil).find_each do |aliquot|
        aliquot.update!(uuid: SecureRandom.uuid)
      end
    end
  end
end

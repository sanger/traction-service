# frozen_string_literal: true

# Rake tasks associated with aliquots namespace
namespace :aliquots do
  desc 'Update aliquots with UUID'
  task update_aliquots_with_uuid: :environment do
    puts '-> Updating aliquots with UUID'

    ActiveRecord::Base.transaction do
      # If an aliquot does not have a UUID set it
      Aliquot.where(uuid: nil).find_each do |aliquot|
        aliquot.update!(uuid: SecureRandom.uuid.to_s)
      end
    end
  end
end

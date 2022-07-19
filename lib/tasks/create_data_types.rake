# frozen_string_literal: true

namespace :data_types do
  desc 'Create data types'
  task create: :environment do
    [
      { pipeline: 'ont', name: 'basecalls' },
      { pipeline: 'ont', name: 'basecalls and raw data' }
    ].each do |options|
      DataType.create_with(options).find_or_create_by!(name: options[:name])
    end
    puts '-> Data types updated'
  end
end

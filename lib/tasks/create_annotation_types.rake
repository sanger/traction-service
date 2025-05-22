# frozen_string_literal: true

namespace :annotation_types do
  desc 'Create annotation types'
  task create: :environment do
    [
      { name: 'Top up' },
      { name: 'Sequencing only' },
      { name: 'Non-barcoded' },
      { name: 'R&D cell' }
    ].each do |options|
      AnnotationType.create_with(options).find_or_create_by!(name: options[:name])
    end
    puts '-> Annotation types updated'
  end
end

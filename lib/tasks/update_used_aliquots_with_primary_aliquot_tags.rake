# frozen_string_literal: true

namespace :used_aliquots do
  task update_tags: :environment do
    libraries = Pacbio::Library.all.reject { |library| library.used_aliquots.first.tag == library.tag }
    libraries.each do |library|
      library.used_aliquots.each do |used_aliquot|
        used_aliquot.update!(tag: library.tag)
        library.wells.collect(&:run).uniq.each do |run|
          Messages.publish(run, Pipelines.pacbio.message)
        end
      end
    end
    puts "-> #{libraries.count} instances of libraries updated."
  end
end

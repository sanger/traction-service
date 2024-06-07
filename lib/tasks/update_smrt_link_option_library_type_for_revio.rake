# frozen_string_literal: true

namespace :pacbio_run do
  task update_smrt_link_option_library_type_for_revio: :environment do
    runs = Pacbio::Run.where(system_name: 'Revio')
    runs.each do |run|
      run.wells.each do |well|
        well.library_type = 'Standard'
        well.save!
      end
    end
    puts "-> #{runs.length} instances of smrt_link_options library_type updated."
  end
end

# frozen_string_literal: true

namespace :pacbio_run do
  task update_smrt_link_option_library_type_for_revio: :environment do
    runs = Pacbio::Run.where(system_name: 'Revio')
    number_of_wells = runs.collect { |run| run.update_smrt_link_options(library_type: 'Standard') }.sum
    puts "-> #{number_of_wells} instances of smrt_link_options library_type updated."
  end
end

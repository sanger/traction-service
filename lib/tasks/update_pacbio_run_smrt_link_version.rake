# frozen_string_literal: true

namespace :pacbio_run do
  task update_smrt_link_version: :environment do
    runs = Pacbio::Run.where(smrt_link_version: '')
    runs.each do |run|
      run.update(smrt_link_version: Version::SmrtLink::DEFAULT)
    end
    puts "-> #{runs.length} instances of nil smrt_link_version updated."
  end
end

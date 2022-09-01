# frozen_string_literal: true

namespace :pacbio_wells do
  task migrate_smrt_link_options: :environment do
    hifi_options = { 0 => 'In SMRT Link', 1 => 'On Instrument', 2 => 'Do Not Generate' }
    # We have to assume it is v10
    wells = Pacbio::Well.all
    wells.each do |well|
      if well.generate_hifi_deprecated.present?
        well.generate_hifi = hifi_options[well.generate_hifi_deprecated]
      end

      if well.ccs_analysis_output_deprecated.present?
        well.ccs_analysis_output = well.ccs_analysis_output_deprecated
      end

      well.save!
    end

    puts "-> #{wells.length} instances of pacbio well updated."
  end
end

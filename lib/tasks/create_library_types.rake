# frozen_string_literal: true

namespace :library_types do
  desc 'Create library types'
  task create: :environment do
    [
      { pipeline: 'pacbio', name: 'Pacbio_HiFi', external_identifier: 'HiFi Reads' },
      { pipeline: 'pacbio', name: 'Pacbio_HiFi_mplx', external_identifier: 'HiFi Reads' },
      { pipeline: 'pacbio', name: 'Pacbio_Microbial_mplx', external_identifier: 'Microbial Assembly' },
      { pipeline: 'pacbio', name: 'Pacbio_IsoSeq', external_identifier: 'Iso-Seq Method' },
      { pipeline: 'pacbio', name: 'PacBio_IsoSeq_mplx', external_identifier: 'Iso-Seq Method' },
      { pipeline: 'pacbio', name: 'PacBio_Ultra_Low_Input', external_identifier: 'HiFi Reads' },
      { pipeline: 'pacbio', name: 'PacBio_Ultra_Low_Input_mplx', external_identifier: 'HiFi Reads' },
      { pipeline: 'pacbio', name: 'Pacbio_Amplicon', external_identifier: 'HiFi Reads' },
      { pipeline: 'ont', name: 'ONT_GridIon' },
      { pipeline: 'ont', name: 'ONT_GridIon_mplx' },
      { pipeline: 'ont', name: 'ONT_PromethIon' },
      { pipeline: 'ont', name: 'ONT_PromethIon_mplx' },
      { pipeline: 'ont', name: 'ONT_PromethIon_High_Quality' },
      { pipeline: 'ont', name: 'ONT_Ultralong' }
    ].each do |options|
      LibraryType.create_with(options).find_or_create_by!(name: options[:name])
    end
    puts '-> Library types updated'
  end
end

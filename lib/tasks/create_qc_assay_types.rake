# frozen_string_literal: true

namespace :qc_assay_types do
  desc 'Create QC Assay Types'
  task create: :environment do
    [
      { key: 'tissue_mass', label: 'Tissue mass', units: 'mg' },
      { key: 'qubit', label: 'Qubit', units: 'ng/μl' },
      { key: 'extraction_yield', label: 'Extraction yield', units: 'ng' },
      { key: 'nanodrop_concentration', label: 'Nanodrop concentration', units: 'ng/μl' },
      { key: '260_230_ratio_extraction', label: '260/ 230 ratio extraction', units: '' },
      { key: '260_280_ratio_extraction', label: '260/ 280 ratio extraction', units: '' },
      { key: 'femto_profile_description', label: 'Femto profile description', units: '' },
      { key: 'femto_profile_link', label: 'Femto profile link', units: '' },
      { key: 'gqn_threshold_30kb', label: 'GQN with threshold at 30Kb', units: '' },
      { key: 'extraction_result', label: 'Extraction result (pass/fail/hold)', units: '' },
      { key: 'yield_post_0.45x_clean_up', label: 'Yield post 0.45X clean up', units: '' },
      { key: 'qubit_post_45x_clean_up', label: 'Qubit post 0.45X clean up', units: 'ng/μl' },
      { key: 'mode_length_dna_sheared_pacbio', label: 'Mode length of DNA sheared for PacBio', units: 'bp' },
      { key: 'gqn_threshold_10kb', label: 'GQN with threshold at 10Kb', units: '' },
      { key: 'qubit_post_shear_spri_45.4μl', label: 'Qubit (post shear:SPRI ng/μl in 45.4μl)', units: 'ng/μl' },
      { key: '260_280_ratio_post_shear_spri', label: '260/280 ratio post shear:SPRI', units: '' },
      { key: '260_230_ratio_post_shear_spri', label: '260/230 ratio post shear:SPRI', units: '' },
      { key: 'pre_library_yield', label: 'Pre-library yield', units: '' },
      { key: 'percent_dna_recovery_post_spri_pre_shear', label: '% DNA recovery (into shear - after SPRI)', units: '%' },
      { key: 'shear_spri_result', label: 'Shear/SPRI result (pass/fail/hold)', units: '' }
    ].each do |options|
      QcAssayType.create_with(options).find_or_create_by!(key: options[:key])
    end
    puts '-> QC Assay Types updated'
  end
end

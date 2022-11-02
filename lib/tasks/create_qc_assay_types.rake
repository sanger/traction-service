# frozen_string_literal: true

namespace :qc_assay_types do
  desc 'Create QC Assay Types'
  task create: :environment do
    [
      { key: 'sample_tube', label: 'DNA tube ID' },
      { key: 'qubit_concentration_ngul', label: 'Qubit DNA Quant (ng/ul)' },
      { key: 'volume_si', label: 'DNA vol (ul)' },
      { key: 'yield', label: 'DNA total ng' },
      { key: '_260_230_ratio', label: 'ND 260/230' },
      { key: '_260_280_ratio', label: 'ND 260/280' },
      { key: 'nanodrop_concentration_ngul', label: 'ND Quant (ng/ul)' },
      { key: 'gqn_dnaex', label: 'GQN >30000' },
      { key: 'results_pdf', label: 'Femto pdf' }
    ].each do |options|
      QcAssayType.create_with(options).find_or_create_by!(key: options[:key])
    end
    puts '-> QC Assay Types updated'
  end
end

# frozen_string_literal: true

namespace :qc_assay_types do
  desc 'Create QC Assay Types'
  task create: :environment do

    QcAssayType.destroy_all

    [
      { key: 'qubit_concentration_ngul', label: 'Qubit DNA Quant (ng/ul)', used_by: 0 },
      { key: 'volume_si', label: 'DNA vol (ul)', used_by: 0 },
      { key: 'yield', label: 'DNA total ng', used_by: 0 },
      { key: '_260_230_ratio', label: 'ND 260/230', used_by: 0 },
      { key: '_260_280_ratio', label: 'ND 260/280', used_by: 0 },
      { key: 'nanodrop_concentration_ngul', label: 'ND Quant (ng/ul)', used_by: 0 },
      { key: '_tbc_', label: 'Femto Frag Size', used_by: 0 },
      { key: 'gqn_dnaex', label: 'GQN >30000', used_by: 0 },
      { key: 'results_pdf', label: 'Femto pdf [post-extraction]', used_by: 0 }
      # ......
    ].each do |options|
      QcAssayType.create_with(options).find_or_create_by!(key: options[:key])
    end
    puts '-> QC Assay Types updated'
  end
end

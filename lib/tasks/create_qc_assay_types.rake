# frozen_string_literal: true

namespace :qc_assay_types do
  desc 'Create QC Assay Types'
  task create: :environment do
    QcAssayType.destroy_all

    # label has to match the header in the uploaded CSV file
    [
      { key: 'qubit_concentration_ngul', label: 'Qubit DNA Quant (ng/ul) [ESP1]', used_by: 0 },
      { key: 'volume_si', label: 'DNA vol (ul)', used_by: 0 },
      { key: 'yield', label: 'DNA total ng [ESP1]', used_by: 0 },
      { key: '_260_230_ratio', label: 'ND 260/230 [ESP1]', used_by: 0 },
      { key: '_260_280_ratio', label: 'ND 260/280 [ESP1]', used_by: 0 },
      { key: 'nanodrop_concentration_ngul', label: 'ND Quant (ng/ul) [ESP1]', used_by: 0 },
      { key: 'average_fragment_size', label: 'Femto Frag Size [ESP1]', used_by: 0 },
      { key: 'gqn_dnaex', label: 'GQN >30000 [ESP1]', used_by: 0 },
      { key: 'results_pdf', label: 'Femto pdf [ESP1]', used_by: 0 }
      # ......
    ].each do |options|
      QcAssayType.create_with(options).find_or_create_by!(key: options[:key])
    end
    puts '-> QC Assay Types updated'
  end
end

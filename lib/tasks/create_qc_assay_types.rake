# frozen_string_literal: true

# When wanting to add other QC Results to be stored in the future for different groups:
# 1. Add `used_by` enum option to QcAssayType
# 2. Add persist more QcResult's, add fields to `create_qc_assay_types.rake` with the correct `used_by`
# 3. Ensure the QcAssayType `label` is the expected CSV header column name, and the `key` is expected by TOL

namespace :qc_assay_types do
  desc 'Create QC Assay Types'
  task create: :environment do
    [
      { key: 'qubit_concentration_ngul', label: 'Qubit DNA Quant (ng/ul) [ESP1]', used_by: 0, units: 'ng/ul' },
      { key: 'volume_si', label: 'DNA vol (ul)', used_by: 0, units: 'ul' },
      { key: 'yield', label: 'DNA total ng [ESP1]', used_by: 0, units: 'ng' },
      { key: '_260_230_ratio', label: 'ND 260/230 [ESP1]', used_by: 0, units: '' },
      { key: '_260_280_ratio', label: 'ND 260/280 [ESP1]', used_by: 0, units: '' },
      { key: 'nanodrop_concentration_ngul', label: 'ND Quant (ng/ul) [ESP1]', used_by: 0, units: 'ng/ul' },
      { key: 'average_fragment_size', label: 'Femto Frag Size [ESP1]', used_by: 0, units: 'Kb' },
      { key: 'gqn_dnaex', label: 'GQN >30000 [ESP1]', used_by: 0, units: '' },
      { key: 'results_pdf', label: 'Femto pdf [ESP1]', used_by: 0, units: '' },
      { key: 'sheared_femto_fragment_size', label: 'Sheared Femto Fragment Size (bp)', used_by: 1, units: 'bp' },
      { key: 'post_spri_concentration', label: 'Post SPRI Concentration (ng/ul)', used_by: 1, units: 'ng/ul' },
      { key: 'post_spri_volume', label: 'Post SPRI Volume (ul)', used_by: 1, units: 'ul' },
      { key: 'final_nano_drop_280', label: 'Final NanoDrop 260/280', used_by: 1, units: '' },
      { key: 'final_nano_drop_230', label: 'Final NanoDrop 260/230', used_by: 1, units: '' },
      { key: 'final_nano_drop', label: 'Final NanoDrop ng/ul', used_by: 1, units: 'ng/ul' },
      { key: 'shearing_qc_comments', label: 'Shearing & QC comments (if applicable)', used_by: 1, units: '' }
    ].each do |options|
      QcAssayType.create_with(options).find_or_create_by!(key: options[:key])
    end
    puts '-> QC Assay Types updated'
  end
end

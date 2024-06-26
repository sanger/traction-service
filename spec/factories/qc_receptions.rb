# frozen_string_literal: true

FactoryBot.define do
  qc_results_list =
    [
      {
        final_nano_drop: '200',
        final_nano_drop_230: '230',
        final_nano_drop_280: '280',
        post_spri_concentration: '10',
        post_spri_volume: '20',
        sheared_femto_fragment_size: '5',
        shearing_qc_comments: 'Comments',
        date_submitted: '1689078551564.2458',
        labware_barcode: 'FD20706500',
        sample_external_id: 'supplier_sample_name_DDD'
      }
    ]
  qc_results_list_stringified = qc_results_list.map(&:stringify_keys)

  factory :qc_reception do
    source { 'tol-lab-share.tol' }
    qc_results_list { qc_results_list_stringified }
  end

  factory :qc_receptions_factory, class: 'QcReceptionsFactory' do
    qc_reception
  end
end

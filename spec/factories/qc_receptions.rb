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
        date_required_by: 'Long Read',
        date_submitted: '1689078551564.2458',
        labware_barcode: 'FD20706500',
        priority_level: 'Medium',
        reason_for_priority: 'Reason goes here',
        sample_external_id: 'supplier_sample_name_DDD'
      }
    ]
  qc_results_list_stringified = []
  qc_results_list.each do |qc_hash|
    qc_results_list_stringified << qc_hash.stringify_keys
  end

  factory :qc_reception do
    source { 'tol-lab-share.tol' }
    # TODO: DPL-754: Don't think the below should be here, it lives with the factory
    qc_results_list { qc_results_list_stringified }
  end

  factory :qc_receptions_factory, class: 'QcReceptionsFactory' do
    qc_reception { create(:qc_reception) }
    qc_results_list { qc_results_list_stringified }
  end
end

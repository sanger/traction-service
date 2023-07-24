# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QcReceptionsFactory do
  before do
    create(:qc_assay_type, key: 'sheared_femto_fragment_size', label: 'Sheared Femto Fragment Size (bp)', used_by: 2, units: 'bp')
    create(:qc_assay_type, key: 'post_spri_concentration', label: 'Post SPRI Concentration (ng/ul)', used_by: 2, units: 'ng/ul')
    create(:qc_assay_type, key: 'post_spri_volume', label: 'Post SPRI Volume (ul)', used_by: 2, units: 'ul')
    create(:qc_assay_type, key: 'final_nano_drop_280', label: 'Final NanoDrop 260/280', used_by: 2, units: '')
    create(:qc_assay_type, key: 'final_nano_drop_230', label: 'Final NanoDrop 260/230', used_by: 2, units: '')
    create(:qc_assay_type, key: 'final_nano_drop', label: 'Final NanoDrop ng/ul', used_by: 2, units: 'ng/ul')
    create(:qc_assay_type, key: 'shearing_qc_comments', label: 'Shearing & QC comments (if applicable)', used_by: 2, units: '')
  end

  describe '#qc_results_list' do
    let(:factory) { build(:qc_receptions_factory) }

    it 'returns qc_results_list' do
      expect(factory.qc_results_list).to eq factory.qc_reception.qc_results_list
    end
  end

  describe '#create_qc_results' do
    let(:factory) { build(:qc_receptions_factory) }

    context 'when the data is valid' do
      it 'creates QC Results' do
        expect do
          factory.create_qc_results!
        end.to change(QcResult, :count).by 7
      end
    end

    context 'when the qc_results_list is empty' do
      let(:qc_reception) { build(:qc_reception, qc_results_list: [{}]) }
      let(:factory) { build(:qc_receptions_factory, qc_reception:, qc_results_list: [{}]) }

      it 'does not create qc_reception record' do
        expect do
          factory.create_qc_results!
        end.not_to change(QcReception, :count)
      end
    end

    context 'when QC Assay Types mismatch with qc_results_list' do
      let(:qc_results_with_mismatch) do
        [
          {
            'mismatched_key' => '3.3545',
            'some_other_key' => '0.09',
            'final_nano_drop_280' => '280',
            'post_spri_concentration' => '10',
            'post_spri_volume' => '20',
            'shearing_qc_comments' => 'Comments',
            'date_required_by' => 'Long Read',
            'date_submitted' => '1689078551564.2458',
            'labware_barcode' => 'FD20706500',
            'priority_level' => 'Medium',
            'reason_for_priority' => 'Reason goes here',
            'sample_external_id' => 'supplier_sample_name_DDD'
          }
        ]
      end
      let(:qc_reception) { build(:qc_reception, qc_results_list: qc_results_with_mismatch) }
      let(:factory) { build(:qc_receptions_factory, qc_reception:, qc_results_list: qc_results_with_mismatch) }

      it 'ignores the missing/mistmatch assay_types and fetches the others' do
        fetched_assay_types = factory.assay_types
        expect(fetched_assay_types.keys.include?('mismatched_key')).to be false
        expect(fetched_assay_types.keys.include?('some_other_key')).to be false
        expect(fetched_assay_types.keys.include?('final_nano_drop_280')).to be true
        expect(fetched_assay_types.keys.include?('post_spri_concentration')).to be true
        expect(fetched_assay_types.keys.include?('post_spri_volume')).to be true
        expect(fetched_assay_types.keys.include?('shearing_qc_comments')).to be true
      end

      it 'creates the correct number of QC Results records that matches the QC Assay Types' do
        expect do
          factory.create_qc_results!
        end.to change(QcResult, :count).by 4
      end
    end
  end

  describe '#messages' do
    let(:factory) { build(:qc_receptions_factory) }

    context 'when the data is valid' do
      it 'builds the correct qc results message' do
        factory.create_qc_results!
        messages = factory.messages
        expect(messages.count).to eq 7
        expect(QcResult.find(messages[0].id).labware_barcode).to eq(messages[0].labware_barcode)
        expect(QcResult.find(messages[0].id).sample_external_id).to eq(messages[0].sample_external_id)
        expect(QcResult.find(messages[0].id).qc_assay_type_id).to eq(messages[0].qc_assay_type_id)
        expect(QcResult.find(messages[0].id).value).to eq(messages[0].value)
        expect(QcResult.find(messages[0].id).priority_level).to eq(messages[0].priority_level)
        expect(QcResult.find(messages[0].id).reason_for_priority).to eq(messages[0].reason_for_priority)
        expect(QcResult.find(messages[0].id).date_required_by).to eq(messages[0].date_required_by)
      end
    end
  end
end

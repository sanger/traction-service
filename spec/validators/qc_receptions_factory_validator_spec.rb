# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QcReceptionsFactoryValidator do
  describe '#validate' do
    let(:used_by) { 'tol' }
    let(:record) { build(:qc_receptions_factory) }

    before do
      create(:qc_assay_type, key: 'qubit_concentration_ngul', label: 'Qubit DNA Quant (ng/ul) [ESP1]', used_by: 0, units: 'ng/ul')
      create(:qc_assay_type, key: 'sheared_femto_fragment_size', label: 'Sheared Femto Fragment Size (bp)', used_by: 1, units: 'bp')
      create(:qc_assay_type, key: 'post_spri_concentration', label: 'Post SPRI Concentration (ng/ul)', used_by: 1, units: 'ng/ul')
      create(:qc_assay_type, key: 'post_spri_volume', label: 'Post SPRI Volume (ul)', used_by: 1, units: 'ul')
      create(:qc_assay_type, key: 'final_nano_drop_280', label: 'Final NanoDrop 260/280', used_by: 1, units: '')
      create(:qc_assay_type, key: 'final_nano_drop_230', label: 'Final NanoDrop 260/230', used_by: 1, units: '')
      create(:qc_assay_type, key: 'final_nano_drop', label: 'Final NanoDrop ng/ul', used_by: 1, units: 'ng/ul')
      create(:qc_assay_type, key: 'shearing_qc_comments', label: 'Shearing & QC comments (if applicable)', used_by: 1, units: '')
    end

    context 'valid' do
      before do
        described_class.new.validate(record)
      end

      it 'does not add an error to the record' do
        expect(record).to be_valid
      end
    end

    describe '#validate_qc_results_list' do
      it 'when qc_results_list is an empty array' do
        qc_reception = build(:qc_reception, qc_results_list: [])
        record = build(:qc_receptions_factory, qc_reception:)
        described_class.new.validate(record)
        expect(record).not_to be_valid
        expect(record.errors.messages[:qc_results_list]).to eq ["can't be blank"]
      end

      it 'when qc_results_list is an array with empty hash' do
        qc_reception = build(:qc_reception, qc_results_list: [{}])
        record = build(:qc_receptions_factory, qc_reception:)
        described_class.new.validate(record)
        expect(record).not_to be_valid
        expect(record.errors.messages[:qc_results_list]).to eq ['Is empty']
      end
    end

    describe '#validate_assay_type' do
      it 'when no matching assay types in qc_results_list' do
        qc_reults_list = [
          {
            'qubit_concentration_ngul' => '5.6',
            'date_submitted' => '1689078551564.2458',
            'labware_barcode' => 'FD20706500',
            'sample_external_id' => 'supplier_sample_name_DDD'
          }
        ]
        qc_reception = build(:qc_reception, qc_results_list: qc_reults_list)
        record = build(:qc_receptions_factory, qc_reception:, qc_results_list: qc_reults_list)
        described_class.new.validate(record)
        expect(record).not_to be_valid
        expect(record.errors.messages[:qc_results_list]).to eq ['No valid Qc fields']
      end
    end
  end
end

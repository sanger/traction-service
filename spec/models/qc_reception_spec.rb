# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QcReception do
  describe '#create' do
    before do
      create(:qc_assay_type, key: 'sheared_femto_fragment_size', label: 'Sheared Femto Fragment Size (bp)', used_by: 2, units: 'bp')
    end

    let(:qc_reception) { build(:qc_reception) }

    it 'is possible to create a new record' do
      expect do
        described_class.create!(
          source: qc_reception.source,
          qc_results_list: qc_reception.qc_results_list
        )
      end.to change(described_class, :count).by(1)
    end

    describe '#validates_nested' do
      it 'errors if missing required source field' do
        expect do
          described_class.create!(qc_results_list: qc_reception.qc_results_list)
        end.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'errors if missing required qc_results_list' do
        expect do
          described_class.create!(source: qc_reception.source)
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe '#check delegation' do
    it { is_expected.to delegate_method(:create_qc_results!).to(:qc_receptions_factory) }
    it { is_expected.to delegate_method(:messages).to(:qc_receptions_factory) }
  end
end

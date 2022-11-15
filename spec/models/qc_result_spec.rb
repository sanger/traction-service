# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QcResult, type: :model do
  let(:qc_assay_type) { create :qc_assay_type }

  describe '#create' do
    it 'is possible to create a new record' do
      expect do
        described_class.create!(
          labware_barcode: 'YZ1234',
          sample_external_id: 'any_id',
          qc_assay_type:,
          value: 'the result'
        )
      end.to change(described_class, :count).by(1)
    end

    it 'errors if missing required relationship' do
      expect do
        described_class.create!(
          labware_barcode: 'YZ1234',
          sample_external_id: 'any_id',
          value: 'the result'
        )
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'errors if missing required fields' do
      expect { described_class.create!(qc_assay_type:) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#update' do
    let(:result) { create :qc_result }

    it 'is possible to update a record' do
      expect(result.value).not_to eq('a new value')
      result.update!(value: 'a new value')
      expect(result.value).to eq('a new value')
    end
  end

  describe '#destroy' do
    it 'is possible to destroy a record' do
      qc_result = create(:qc_result)
      expect { qc_result.destroy! }.to change(described_class, :count).by(-1)
    end

    it 'can be destroyed if there are no associated qc_decision_results' do
      qc_result = create(:qc_result)
      expect do
        qc_result.destroy!
      end.not_to raise_error(ActiveRecord::RecordNotDestroyed)
    end

    it 'cannot be destroyed if there are any associated qc_decision_results' do
      qc_result = create(:qc_result)
      qc_decision = create(:qc_decision)
      create(:qc_decision_result, qc_decision:, qc_result:)
      expect do
        qc_result.destroy!
      end.to raise_error(ActiveRecord::RecordNotDestroyed)
    end
  end

  describe 'associations' do
    let(:qc_result) { create(:qc_result) }
    let(:qc_decision) { create(:qc_decision) }
    let(:qc_decision_result) { create(:qc_decision_result, qc_decision:, qc_result:) }

    it 'has the correct associations' do
      expect(qc_result.qc_decision_results).to eq [qc_decision_result]
      expect(qc_result.qc_decisions).to eq [qc_decision]
    end

    # when there is more than one
  end
end

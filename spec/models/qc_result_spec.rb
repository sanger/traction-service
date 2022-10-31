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
          value: 'the result',
          status: :pass,
          decision_made_by: :tol
        )
      end.to change(described_class, :count).by(1)
    end

    it 'errors if missing required relationship' do
      expect do
        described_class.create!(
          labware_barcode: 'YZ1234',
          sample_external_id: 'any_id',
          value: 'the result',
          status: :pass,
          decision_made_by: :tol
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
    let!(:result) { create :qc_result }

    it 'is possible to destroy a record' do
      expect { result.destroy! }.to change(described_class, :count).by(-1)
    end
  end

  describe '#status' do
    it { is_expected.to define_enum_for(:status).with(%i[pass fail failed_profile on_hold_uli review na_control]) }
  end

  describe '#decision_made_by' do
    it { is_expected.to define_enum_for(:decision_made_by).with(%i[long_read tol]) }

    it 'errors if missing required decision_made_by' do
      expect do
        described_class.create!(
          labware_barcode: 'YZ1234',
          sample_external_id: 'any_id',
          qc_assay_type:,
          value: 'the result',
          status: :pass
        )
      end.to raise_error(ActiveRecord::NotNullViolation)
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QcDecision, type: :model do

  describe '#create' do
    it 'is possible to create a new record' do
      expect do
        described_class.create!(
          barcode: 'YZ1234',
          status: :pass,
          decision_made_by: :tol
        )
      end.to change(described_class, :count).by(1)
    end
  end

  describe '#status' do
    let(:result) { create :qc_decision }

    it 'has a status' do
      expect(result.status).to be_present
      expect(result.status).to eq 'pass'
    end
  end

  describe '#decision_made_by' do
    it { is_expected.to define_enum_for(:decision_made_by).with(%i[long_read tol]) }

    it 'errors if missing required decision_made_by' do
      expect do
        described_class.create!(
          barcode: 'YZ1234',
          status: :pass
        )
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end

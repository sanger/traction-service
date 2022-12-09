# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QcDecision, type: :model do
  describe '#create' do
    it 'is possible to create a new record' do
      expect do
        described_class.create!(
          status: :pass,
          decision_made_by: :tol
        )
      end.to change(described_class, :count).by(1)
    end
  end

  describe '#destroy' do
    it 'is possible to destroy a record' do
      qc_decision = create(:qc_decision)
      expect { qc_decision.destroy! }.to change(described_class, :count).by(-1)
    end

    it 'can be destroyed if there are no associated qc_decision_results' do
      qc_decision = create(:qc_decision)
      expect do
        qc_decision.destroy!
      end.not_to raise_error
    end

    it 'cannot be destroyed if there are any associated qc_decision_results' do
      qc_decision = create(:qc_decision)
      qc_result = create(:qc_result)
      create(:qc_decision_result, qc_decision:, qc_result:)
      expect do
        qc_decision.destroy!
      end.to raise_error(ActiveRecord::RecordNotDestroyed)
    end
  end

  describe '#status' do
    let(:result) { create :qc_decision }

    it 'has a status' do
      expect(result.status).to be_present
      expect(result.status).to eq 'pass'
    end

    it 'errors if missing required status' do
      expect do
        described_class.create!(
          decision_made_by: :tol
        )
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#decision_made_by' do
    it { is_expected.to define_enum_for(:decision_made_by).with_values(%i[long_read tol]) }

    it 'errors if missing required decision_made_by' do
      expect do
        described_class.create!(
          status: :pass
        )
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'associations' do
    let(:qc_decision) { create(:qc_decision) }
    let(:qc_result) { create(:qc_result) }
    let(:qc_decision_result) { create(:qc_decision_result, qc_decision:, qc_result:) }

    it 'has the correct associations' do
      expect(qc_decision.qc_decision_results).to eq [qc_decision_result]
      expect(qc_decision.qc_results).to eq [qc_result]
    end

    # when there is more than one
  end
end

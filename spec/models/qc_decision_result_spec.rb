# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QcDecisionResult, type: :model do
  let(:qc_decision) { create(:qc_decision) }
  let(:qc_result) { create(:qc_result) }
  let(:qc_decision_result) { create(:qc_decision_result) }

  describe '#create' do
    it { is_expected.to belong_to :qc_result }
    it { is_expected.to belong_to :qc_decision }

    it 'is created with a qc_decision and qc_result' do
      expect(qc_decision_result.qc_decision).to be_present
      expect(qc_decision_result.qc_result).to be_present
    end

    it 'is possible to create a new record' do
      expect do
        described_class.create!(
          qc_decision:,
          qc_result:
        )
      end.to change(described_class, :count).by(1)
    end
  end

  describe '#destroy' do
    it 'is possible to destroy a record' do
      qc_decision = create(:qc_decision)
      qc_result = create(:qc_result)
      qc_decision_result = create(:qc_decision_result, qc_decision:, qc_result:)
      expect { qc_decision_result.destroy! }.to change(described_class, :count).by(-1)
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to :qc_result }
    it { is_expected.to belong_to :qc_decision }

    it 'is created with a qc_decision and qc_result' do
      expect(qc_decision_result.qc_decision).to be_present
      expect(qc_decision_result.qc_result).to be_present
    end

    # when there is more than one
  end

  describe '#qc_decision_id' do
    it 'errors if foreign key constraint is null' do
      expect do
        described_class.create!(
          qc_result_id: qc_result.id
        )
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'errors if foreign key constraint is not met' do
      expect do
        described_class.create!(
          qc_decision_id: 1,
          qc_result_id: qc_result.id
        )
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#qc_result_id' do
    it 'errors if foreign key constraint is null' do
      expect do
        described_class.create!(
          qc_decision_id: qc_decision.id
        )
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'errors if foreign key constraint is not met' do
      expect do
        described_class.create!(
          qc_decision_id: qc_decision.id,
          qc_result_id: 1
        )
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end

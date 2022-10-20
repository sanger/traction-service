# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QcAssayType, type: :model do
  describe '#create' do
    it 'is possible to create a new record' do
      expect { described_class.create!(key: 'qubit', label: 'Qubit', units: 'ng/μl') }.to change(described_class, :count).by(1)
    end

    it 'errors if missing required fields' do
      expect { described_class.create! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#update' do
    let(:assay_type) { create :qc_assay_type }

    it 'is possible to update a record' do
      expect(assay_type.units).not_to eq('fakeunit')
      assay_type.update!(units: 'fakeunit')
      expect(assay_type.units).to eq('fakeunit')
    end
  end

  describe '#destroy' do
    let!(:assay_type) { create :qc_assay_type }

    it 'is possible to destroy a record' do
      expect { assay_type.destroy! }.to change(described_class, :count).by(-1)
    end
  end
end

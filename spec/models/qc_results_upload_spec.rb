# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QcResultsUpload, type: :model do
  describe '#create' do
    it 'is possible to create a new record' do
      expect do
        described_class.create!(
          csv_data: 'a,b,c\n',
          used_by: 'extraction'
        )
      end.to change(described_class, :count).by(1)
    end

    it 'errors if missing required csv_data field' do
      expect do
        described_class.create!(used_by: 'extraction')
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'errors if missing required used_by field' do
      expect do
        described_class.create!(csv_data: 'a,b,c\n')
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#create_entities!' do
    it { is_expected.to delegate_method(:create_entities!).to(:qc_results_upload_factory) }
  end
end

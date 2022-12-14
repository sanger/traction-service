# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QcResultsUpload do
  describe '#create' do
    let(:qc_results_upload) { build(:qc_results_upload) }

    it 'is possible to create a new record' do
      expect do
        described_class.create!(
          csv_data: qc_results_upload.csv_data,
          used_by: qc_results_upload.used_by
        )
      end.to change(described_class, :count).by(1)
    end


    describe '#validates_nested' do
      # DPL-478 todo
      # it calls the validation before creating entity
      # if any fail, QcResultsUpload is not created
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
  end

  describe '#create_entities!' do
    it { is_expected.to delegate_method(:create_entities!).to(:qc_results_upload_factory) }

    # DPL-478 todo
    # delegate messages method
  end
end

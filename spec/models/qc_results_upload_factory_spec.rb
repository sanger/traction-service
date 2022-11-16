# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QcResultsUploadFactory, type: :model do
  describe '#create_entities!' do
    let(:factory) { build(:qc_results_upload_factory) }

    it 'returns true' do
      expect(factory.create_entities!).to be true
    end
  end

  describe '#get_csv_data' do
    let(:factory) { build(:qc_results_upload_factory) }

    it 'returns csv data' do
      expect(factory.get_csv_data).to eq factory.qc_results_upload.csv_data
    end
  end

  describe '#get_used_by' do
    let(:factory) { build(:qc_results_upload_factory) }

    it 'returns used_by' do
      expect(factory.get_used_by).to eq factory.qc_results_upload.used_by
    end
  end

  describe '#csv_rows' do
    let(:factory) { build(:qc_results_upload_factory) }

    it 'returns the rows of the csv' do
      expect(factory.csv_rows.length).to eq 4
    end
  end

  describe '#csv_headers' do
    let(:factory) { build(:qc_results_upload_factory) }

    it 'returns the csv header row' do
      expect(factory.csv_headers.length).to eq 62
    end
  end

  describe '#csv_body' do
    let(:factory) { build(:qc_results_upload_factory) }

    it 'returns the csv header row' do
      expect(factory.csv_body.length).to eq 2
    end
  end

  describe '#create_qc_decision!' do
    let(:factory) { build(:qc_results_upload_factory) }

    it 'creates a QcDecision entity' do
      expect do
        factory.create_qc_decision!('Pass', :long_read)
      end.to change(QcDecision, :count).by(1)
    end

    it 'raises an error when invalid' do
      expect do
        factory.create_qc_decision!('', :long_read)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#create_qc_result!' do
    let(:factory) { build(:qc_results_upload_factory) }
    let(:qc_assay_type) { create(:qc_assay_type) }

    it 'creates a QcResult entity' do
      expect do
        factory.create_qc_result!('a_labware_barcode', 'a_sample_external_id', qc_assay_type.id, 'a_value')
      end.to change(QcResult, :count).by(1)
    end

    it 'raises an error when invalid' do
      expect do
        factory.create_qc_result!('', '', '', '')
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#create_qc_decision_result!' do
    let(:factory) { build(:qc_results_upload_factory) }
    let(:qc_assay_type) { create(:qc_assay_type) }
    let(:qc_result) { create(:qc_result) }
    let(:qc_decision) { create(:qc_decision) }

    it 'creates a QcDecisionResult entity' do
      expect do
        factory.create_qc_decision_result!(qc_result.id, qc_decision.id)
      end.to change(QcDecisionResult, :count).by(1)
    end

    it 'raises an error when invalid' do
      expect do
        factory.create_qc_decision_result!(1, 2)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end

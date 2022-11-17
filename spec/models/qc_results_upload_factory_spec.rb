# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QcResultsUploadFactory, type: :model do
  describe '#create_entities!' do
    let(:factory) { build(:qc_results_upload_factory) }

    it 'returns true' do
      expect(factory.create_entities!).to be true
    end
  end

  describe '#get_csv_string' do
    let(:factory) { build(:qc_results_upload_factory) }

    it 'returns csv data' do
      expect(factory.get_csv_string).to eq factory.qc_results_upload.csv_data
    end
  end

  describe '#get_used_by' do
    let(:factory) { build(:qc_results_upload_factory) }

    it 'returns used_by' do
      expect(factory.get_used_by).to eq factory.qc_results_upload.used_by
    end
  end

  describe '#csv_string_without_groups' do
    let(:factory) { build(:qc_results_upload_factory) }

    it 'returns the csv header row' do
      expect(factory.csv_string_without_groups).to be_a String
    end
  end

  # create assay types
  describe '#csv_data_to_json' do
    let(:factory) { build(:qc_results_upload_factory) }

    it 'returns the csv header row' do
      expect(factory.csv_data_to_json).to be_a Array
      expect(factory.csv_data_to_json[0]).to be_a Object
      expect(factory.csv_data_to_json[0]["qubit_concentration_ngul"]).to eq 4.78
      expect(factory.csv_data_to_json[0]["volume_si"]).to eq 385
      expect(factory.csv_data_to_json[0]["yield"]).to eq 1840.3
      expect(factory.csv_data_to_json[0]["_260_230_ratio"]).to eq 0.57
      expect(factory.csv_data_to_json[0]["_260_280_ratio"]).to eq 2.38
      expect(factory.csv_data_to_json[0]["nanodrop_concentration_ngul"]).to eq 14.9
      expect(factory.csv_data_to_json[0]["_tbc_"]).to eq 22688
      expect(factory.csv_data_to_json[0]["gqn_dnaex"]).to eq 1.5
      expect(factory.csv_data_to_json[0]["results_pdf"]).to eq "Extraction.Femto.9764-9765"
    end
  end

  describe '#build' do
    let(:factory) { build(:qc_results_upload_factory) }

    it 'returns ' do
      factory.build
      # TODO!
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

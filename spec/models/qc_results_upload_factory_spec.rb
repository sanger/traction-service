# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QcResultsUploadFactory, type: :model do
  before do
    create(:qc_assay_type, key: 'qubit_concentration_ngul', label: 'Qubit DNA Quant (ng/ul)', used_by: 0)
    create(:qc_assay_type, key: 'volume_si', label: 'DNA vol (ul)', used_by: 0)
    create(:qc_assay_type, key: '_260_230_ratio', label: 'ND 260/230', used_by: 0)
    create(:qc_assay_type, key: '_260_280_ratio', label: 'ND 260/280', used_by: 0)
    create(:qc_assay_type, key: '_tbc_', label: 'Femto Frag Size', used_by: 0)
    create(:qc_assay_type, key: 'results_pdf', label: 'Femto pdf [post-extraction]', used_by: 0)
  end

  describe '#create_entities!' do
    let(:factory) { build(:qc_results_upload_factory) }

    xit 'returns true' do
      expect(factory.create_entities!).to be true
    end
  end

  describe '#csv_data' do
    let(:factory) { build(:qc_results_upload_factory) }

    it 'returns csv data' do
      expect(factory.csv_data).to eq factory.qc_results_upload.csv_data
    end
  end

  describe '#used_by' do
    let(:factory) { build(:qc_results_upload_factory) }

    it 'returns used_by' do
      expect(factory.used_by).to eq factory.qc_results_upload.used_by
    end
  end

  describe '#csv_string_without_groups' do
    let(:factory) { build(:qc_results_upload_factory) }

    it 'returns the csv header row' do
      expect(factory.csv_string_without_groups).to be_a String
    end
  end

  describe '#pivot_csv_data_to_obj' do
    let(:factory) { build(:qc_results_upload_factory) }

    it 'returns the csv header row' do
      expect(factory.pivot_csv_data_to_obj).to be_a Array
      expect(factory.pivot_csv_data_to_obj[0]).to be_a Object
      expect(factory.pivot_csv_data_to_obj[0]['qubit_concentration_ngul']).to eq 4.78
      expect(factory.pivot_csv_data_to_obj[0]['volume_si']).to eq 385
      expect(factory.pivot_csv_data_to_obj[0]['_260_230_ratio']).to eq 0.57
      expect(factory.pivot_csv_data_to_obj[0]['_260_280_ratio']).to eq 2.38
      expect(factory.pivot_csv_data_to_obj[0]['_tbc_']).to eq 22688
      expect(factory.pivot_csv_data_to_obj[0]['results_pdf']).to eq 'Extraction.Femto.9764-9765'
    end
  end

  describe '#build' do
    let(:factory) { build(:qc_results_upload_factory) }

    context 'when there is only long read decisions' do
      it 'creates entities' do
        # 7 = 7 rows
        expect do
          factory.build
        end.to change(QcDecision, :count).by(7)

        # 42 = 6 assay types x 7 rows
        expect do
          factory.build
        end.to change(QcResult, :count).by(42)

        # 42 = 6 assay types x 7 rows
        expect do
          factory.build
        end.to change(QcDecisionResult, :count).by(42)
      end
    end
  end

  describe '#create_qc_results' do
    let(:factory) { build(:qc_results_upload_factory) }

    it 'creates QC Results for the correct QC Assay Types' do
      row_object = factory.pivot_csv_data_to_obj[0]

      expect do
        factory.create_qc_results(row_object)
      end.to change(QcResult, :count).by 6
    end

    it 'creates QC Results with the correct data' do
      row_object = factory.pivot_csv_data_to_obj[0]
      qc_result_ids = factory.create_qc_results(row_object)

      expect(qc_result_ids.count).to eq 6
      expect(QcResult.find(qc_result_ids[0]).qc_assay_type.key).to eq 'qubit_concentration_ngul'
      expect(QcResult.find(qc_result_ids[0]).value).to eq '4.78'
      expect(QcResult.find(qc_result_ids[1]).qc_assay_type.key).to eq 'volume_si'
      expect(QcResult.find(qc_result_ids[1]).value).to eq '385'
      expect(QcResult.find(qc_result_ids[2]).qc_assay_type.key).to eq '_260_230_ratio'
      expect(QcResult.find(qc_result_ids[2]).value).to eq '0.57'
      expect(QcResult.find(qc_result_ids[3]).qc_assay_type.key).to eq '_260_280_ratio'
      expect(QcResult.find(qc_result_ids[3]).value).to eq '2.38'
      expect(QcResult.find(qc_result_ids[4]).qc_assay_type.key).to eq '_tbc_'
      expect(QcResult.find(qc_result_ids[4]).value).to eq '22688'
      expect(QcResult.find(qc_result_ids[5]).qc_assay_type.key).to eq 'results_pdf'
      expect(QcResult.find(qc_result_ids[5]).value).to eq 'Extraction.Femto.9764-9765'
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

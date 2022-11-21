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

  describe 'validation' do
    let(:csv_dupl_headers) { ",,SAMPLE INFORMATION,,,,,,,,,,,,,VOUCHERING,,,,EXTRACTION/QC,,,,,,,,,,,,#REF!,,,,,,,,,,,,,,,,,,,,,,,,,,,COLUMN JUST FOR TOL,,SEQUENCING DATA,
    Batch,Tissue Tube ID,Sanger sample ID,Species,Genome Size,Tissue FluidX rack ID,Rack well location,Date,Crush Method,Tissue Mass (mg),Tissue type,Lysis,DNA tube ID,DNAext FluidX Rack ID,Rack position,Voucher?,Voucher Tube ID,Voucher Rack ID,Sample Location,Qubit DNA Quant (ng/ul),DNA vol (ul),DNA total ng,Femto dilution,ND 260/280,ND 260/230,ND Quant (ng/ul),Femto Frag Size,GQN >30000,Femto pdf [post-extraction],LR EXTRACTION DECISION,Sample Well Position in Plate,TOL DECISION [Post-Extraction],Operator,Pre-shear SPRI Vol input (uL),SPRI Volume (x0.6),Final Elution (uL),DNA Fluid+ MR kit for viscous DNA?,MR Machine ID,MR speed,Vol Input DNA MR3 (uL),Save 1uL post shear,Vol Input SPRI (uL),SPRI volume (x0.6),Qubit Quant (ng/ul),Final Elution Volume (ul),Total DNA ng,Femto Dil (ul),ND 260/280,ND 260/230,ND Quant (ng/uL),% DNA Recovery,Femto Fragment size (post-shear),GQN 10kb threshold,Femto pdf [post-shear],LMW Peak PS,Comments,Date Complete,TOL DECISION [Post-Shearing],ToL ID,ToL ID,PB comments/yields,Traction ID
    Production 1,FD20709764,DTOL12932860,,0.53,,,04/05/2022,Powermash,7.8,Non-plant,2h@25C,,,NA,Yes,FD38542652,SA00930879,A1,4.78,385,1840.3,18.12,2.38,0.57,14.9,22688,1.5,Extraction.Femto.9764-9765,Pass,,Pass,lk11,,,,,Alan Shearer/Britney Shears,30,,FALSE,,,22.6,45.4,1026.04,89.4,1.92,1.79,33.7,55.8,9772,4.4,Sheared.Femto.9764-6843,,low fragment size,,,idCheUrba1,idCheUrba1,," }

    let(:qc_results_upload) { build(:qc_results_upload, csv_data: csv_dupl_headers) }
    let(:factory) { build(:qc_results_upload_factory, qc_results_upload: ) }

    it 'errors when there are duplicate headers' do
      expect(factory.valid?).to be false
      expect(factory.errors.messages[:csv_data]).to eq ["Contains duplicated headers", "Another error"]
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
        # 14 = 8 LR + 6 TOL
        expect do
          factory.build
        end.to change(QcDecision, :count).by(14)

        # 42 = 6 assay types x 8 rows
        expect do
          factory.build
        end.to change(QcResult, :count).by(48)

        # row	dec	results	dec_res
        # 1	  2   6	      12
        # 2	  2   6	      12
        # 3	  2   6	      12
        # 4	  2   6	      12
        # 5	  1   6	      6
        # 6	  2   6	      12
        # 7	  1   6	      6
        # 8	  2   6	      12
        #                 84
        expect do
          factory.build
        end.to change(QcDecisionResult, :count).by(84)
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

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QcResultsUploadFactory do
  before do
    Flipper.enable(:dpl_478_enable_qc_results_upload)

    create(:qc_assay_type, key: 'qubit_concentration_ngul', label: 'Qubit DNA Quant (ng/ul) [ESP1]', used_by: 0)
    create(:qc_assay_type, key: 'volume_si', label: 'DNA vol (ul)', used_by: 0)
    create(:qc_assay_type, key: '_260_230_ratio', label: 'ND 260/230 [ESP1]', used_by: 0)
    create(:qc_assay_type, key: '_260_280_ratio', label: 'ND 260/280 [ESP1]', used_by: 0)
    create(:qc_assay_type, key: 'average_fragment_size', label: 'Femto Frag Size [ESP1]', used_by: 0)
    create(:qc_assay_type, key: 'results_pdf', label: 'Femto pdf [ESP1]', used_by: 0)
    create(:qc_assay_type, key: 'some_future_key', label: 'Some Future Label', used_by: 1)
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

  # DPL-478 todo
  # - constants

  describe '#create_entities!' do
    context 'when there is both LR and TOL decsions' do
      let(:factory) { build(:qc_results_upload_factory) }

      it 'creates qc decisions' do
        # 14 = 8 LR + 6 TOL
        expect do
          factory.create_entities!
        end.to change(QcDecision, :count).by(14)
      end

      it 'creates qc results' do
        # 48 = 6 assay types x 8 rows
        expect do
          factory.create_entities!
        end.to change(QcResult, :count).by(48)
      end

      it 'creates qc decision results' do
        # row	dec	results	dec_res
        # 1	  1   6	      6
        # 2	  2   6	      12
        # 3	  1   6	      6
        # 4	  2   6	      12
        # 5	  2   6	      12
        # 6	  2   6	      12
        # 7	  2   6	      12
        # 8	  2   6	      12
        #                 84
        expect do
          factory.create_entities!
        end.to change(QcDecisionResult, :count).by(84)
      end

      it 'messages' do
        factory.create_entities!
        expect(factory.messages.count).to eq(84)
      end
    end

  end

  describe '#create_qc_results' do
    let(:factory) { build(:qc_results_upload_factory) }

    context 'when the data is valid' do
      it 'creates QC Results for the correct QC Assay Types' do
        row_object = factory.pivot_csv_data_to_obj[0]

        expect do
          factory.create_qc_results(row_object)
        end.to change(QcResult, :count).by 6
      end

      it 'creates QC Results with the correct data' do
        row_object = factory.pivot_csv_data_to_obj[0]
        qc_results = factory.create_qc_results(row_object)

        expect(qc_results.count).to eq 6
        expect(QcResult.find(qc_results[0].id).qc_assay_type.key).to eq 'qubit_concentration_ngul'
        expect(QcResult.find(qc_results[0].id).value).to eq '4.78'
        expect(QcResult.find(qc_results[1].id).qc_assay_type.key).to eq 'volume_si'
        expect(QcResult.find(qc_results[1].id).value).to eq '385'
        expect(QcResult.find(qc_results[2].id).qc_assay_type.key).to eq '_260_230_ratio'
        expect(QcResult.find(qc_results[2].id).value).to eq '0.57'
        expect(QcResult.find(qc_results[3].id).qc_assay_type.key).to eq '_260_280_ratio'
        expect(QcResult.find(qc_results[3].id).value).to eq '2.38'
        expect(QcResult.find(qc_results[4].id).qc_assay_type.key).to eq 'average_fragment_size'
        expect(QcResult.find(qc_results[4].id).value).to eq '22688'
        expect(QcResult.find(qc_results[5].id).qc_assay_type.key).to eq 'results_pdf'
        expect(QcResult.find(qc_results[5].id).value).to eq 'Extraction.Femto.9764-9765'
      end
    end

    context 'when there is missing QC Assay Types data' do
      let(:csv_missing_data) do
        ",,SAMPLE INFORMATION,,,,,,,,,,,,,VOUCHERING,,,,EXTRACTION/QC,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,COLUMN JUST FOR TOL,COLUMN JUST FOR TOL,SE LIMS,
        Batch ,Tissue Tube ID,Sanger sample ID,Species,Genome Size,Tissue FluidX rack ID,Rack well location,Date,Crush Method,Tissue Mass (mg),Tissue type,Lysis ,DNA tube ID,DNAext FluidX Rack ID,Rack position,Voucher?,Voucher Tube ID,Voucher Rack ID,Sample Location,Qubit DNA Quant (ng/ul) [ESP1],DNA vol (ul),DNA total ng [ESP1],Femto dilution [ESP1],ND 260/280 [ESP1],ND 260/230 [ESP1],ND Quant (ng/ul) [ESP1],Femto Frag Size [ESP1],GQN >30000 [ESP1],Femto pdf [ESP1],LR EXTRACTION DECISION [ESP1],Sample Well Position in Plate,TOL DECISION [ESP1],DNA Fluid+ MR kit for viscous DNA?,MR Machine ID,MR speed,Vol Input DNA MR3 (uL),Save 1uL post shear,Vol Input SPRI (uL),SPRI volume (x0.6),Qubit Quant (ng/ul) [ESP2],Final Elution Volume (ul),Total DNA ng [ESP2],Femto Dil (ul) [ESP2],ND 260/280 [ESP2],ND 260/230 [ESP2],ND Quant (ng/uL) [ESP2],% DNA Recovery,Femto Fragment size [ESP2],GQN 10kb threshold [ESP2],Femto pdf [ESP2],LR SHEARING DECISION [ESP2],TOL DECISION [ESP2],ToL ID ,Genome size (TOL),SE Number,Date in PB Lab (Auto)
        Production 1,FD20709764,DTOL12932860,,0.53,,,04/05/2022,Powermash,7.8,Non-plant,2h@25C,,,NA,Yes,FD38542652,SA00930879,A1,,385,1840.3,18.12,2.38,0.57,14.9,22688,1.5,Extraction.Femto.9764-9765,Pass,,,,Alan Shearer/Britney Shears,30,,FALSE,,,22.6,45.4,1026.04,89.4,1.92,1.79,33.7,55.8,9772,4.4,Sheared.Femto.9764-6843,Pass,,idCheUrba1,0.52725,SE293337P,24/06/2022"
      end

      let(:qc_results_upload) { build(:qc_results_upload, csv_data: csv_missing_data) }
      let(:factory) { build(:qc_results_upload_factory, qc_results_upload:) }

      it 'ignores them and creates the others' do
        row_object = factory.pivot_csv_data_to_obj[0]

        expect do
          factory.create_qc_results(row_object)
        end.to change(QcResult, :count).by 5
      end
    end
  end

  describe 'validation' do
    context 'when there are missing headers' do
      let(:csv_dupl_headers) { ',,SAMPLE INFORMATION,,,,,,,,,,,,,VOUCHERING,,,,EXTRACTION/QC,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,COLUMN JUST FOR TOL,COLUMN JUST FOR TOL,SE LIMS,' }

      let(:qc_results_upload) { build(:qc_results_upload, csv_data: csv_dupl_headers) }
      let(:factory) { build(:qc_results_upload_factory, qc_results_upload:) }

      it 'errors' do
        expect(factory.valid?).to be false
        expect(factory.errors.messages[:csv_data]).to eq ['Missing headers']
      end
    end

  end

  describe '#create_qc_decision!' do
    let(:factory) { build(:qc_results_upload_factory) }

    context 'when the data is valid' do
      it 'creates a QcDecision entity' do
        expect do
          factory.create_qc_decision!('Pass', :long_read)
        end.to change(QcDecision, :count).by(1)
      end
    end

    context 'when there is missing LR decision' do
      let(:csv_missing_data) do
        ",,SAMPLE INFORMATION,,,,,,,,,,,,,VOUCHERING,,,,EXTRACTION/QC,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,COLUMN JUST FOR TOL,COLUMN JUST FOR TOL,SE LIMS,
        Batch ,Tissue Tube ID,Sanger sample ID,Species,Genome Size,Tissue FluidX rack ID,Rack well location,Date,Crush Method,Tissue Mass (mg),Tissue type,Lysis ,DNA tube ID,DNAext FluidX Rack ID,Rack position,Voucher?,Voucher Tube ID,Voucher Rack ID,Sample Location,Qubit DNA Quant (ng/ul) [ESP1],DNA vol (ul),DNA total ng [ESP1],Femto dilution [ESP1],ND 260/280 [ESP1],ND 260/230 [ESP1],ND Quant (ng/ul) [ESP1],Femto Frag Size [ESP1],GQN >30000 [ESP1],Femto pdf [ESP1],LR EXTRACTION DECISION [ESP1],Sample Well Position in Plate,TOL DECISION [ESP1],DNA Fluid+ MR kit for viscous DNA?,MR Machine ID,MR speed,Vol Input DNA MR3 (uL),Save 1uL post shear,Vol Input SPRI (uL),SPRI volume (x0.6),Qubit Quant (ng/ul) [ESP2],Final Elution Volume (ul),Total DNA ng [ESP2],Femto Dil (ul) [ESP2],ND 260/280 [ESP2],ND 260/230 [ESP2],ND Quant (ng/uL) [ESP2],% DNA Recovery,Femto Fragment size [ESP2],GQN 10kb threshold [ESP2],Femto pdf [ESP2],LR SHEARING DECISION [ESP2],TOL DECISION [ESP2],ToL ID ,Genome size (TOL),SE Number,Date in PB Lab (Auto)
        Production 1,FD20709764,DTOL12932860,,0.53,,,04/05/2022,Powermash,7.8,Non-plant,2h@25C,,,NA,Yes,FD38542652,SA00930879,A1,,385,1840.3,18.12,2.38,0.57,14.9,22688,1.5,Extraction.Femto.9764-9765,Pass,,,,Alan Shearer/Britney Shears,30,,FALSE,,,22.6,45.4,1026.04,89.4,1.92,1.79,33.7,55.8,9772,4.4,Sheared.Femto.9764-6843,Pass,,idCheUrba1,0.52725,SE293337P,24/06/2022"
      end

      let(:qc_results_upload) { build(:qc_results_upload, csv_data: csv_missing_data) }
      let(:factory) { build(:qc_results_upload_factory, qc_results_upload:) }

      it 'ignores them and creates the others' do
        row_object = factory.pivot_csv_data_to_obj[0]

        expect do
          factory.create_qc_results(row_object)
        end.to change(QcResult, :count).by 5
      end
    end

    it 'raises an error when invalid' do
      expect do
        factory.create_qc_decision!('', :long_read)
      end.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Status can't be blank")
    end
  end

  describe '(future proofing)' do
    context 'when there is only one assay type to store' do
      let(:csv_data_extra_header) do
        ",,SAMPLE INFORMATION,,,,,,,,,,,,,VOUCHERING,,,,EXTRACTION/QC,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,COLUMN JUST FOR TOL,COLUMN JUST FOR TOL,SE LIMS,
          Batch ,Tissue Tube ID,Sanger sample ID,Some Future Label,Genome Size,Tissue FluidX rack ID,Rack well location,Date,Crush Method,Tissue Mass (mg),Tissue type,Lysis ,DNA tube ID,DNAext FluidX Rack ID,Rack position,Voucher?,Voucher Tube ID,Voucher Rack ID,Sample Location,Qubit DNA Quant (ng/ul) [ESP1],DNA vol (ul),DNA total ng [ESP1],Femto dilution [ESP1],ND 260/280 [ESP1],ND 260/230 [ESP1],ND Quant (ng/ul) [ESP1],Femto Frag Size [ESP1],GQN >30000 [ESP1],Femto pdf [ESP1],LR EXTRACTION DECISION [ESP1],Sample Well Position in Plate,TOL DECISION [ESP1],DNA Fluid+ MR kit for viscous DNA?,MR Machine ID,MR speed,Vol Input DNA MR3 (uL),Save 1uL post shear,Vol Input SPRI (uL),SPRI volume (x0.6),Qubit Quant (ng/ul) [ESP2],Final Elution Volume (ul),Total DNA ng [ESP2],Femto Dil (ul) [ESP2],ND 260/280 [ESP2],ND 260/230 [ESP2],ND Quant (ng/uL) [ESP2],% DNA Recovery,Femto Fragment size [ESP2],GQN 10kb threshold [ESP2],Femto pdf [ESP2],LR SHEARING DECISION [ESP2],TOL DECISION [ESP2],ToL ID ,Genome size (TOL),SE Number,Date in PB Lab (Auto)
          Production 1,FD20709764,DTOL12932860,some future data,0.53,,,04/05/2022,Powermash,7.8,Non-plant,2h@25C,,,NA,Yes,FD38542652,SA00930879,A1,4.78,385,1840.3,18.12,2.38,0.57,14.9,22688,1.5,Extraction.Femto.9764-9765,Pass,,,,Alan Shearer/Britney Shears,30,,FALSE,,,22.6,45.4,1026.04,89.4,1.92,1.79,33.7,55.8,9772,4.4,Sheared.Femto.9764-6843,Pass,,idCheUrba1,0.52725,SE293337P,24/06/2022"
      end

      let(:qc_results_upload) { build(:qc_results_upload, used_by: :some_future_group, csv_data: csv_data_extra_header) }
      let(:factory) { build(:qc_results_upload_factory, qc_results_upload:) }

      it 'creates entities' do
        expect do
          factory.create_entities!
        end.to change(QcDecision, :count).by(1)

        expect do
          factory.create_entities!
        end.to change(QcResult, :count).by(1)

        expect(QcResult.last.qc_assay_type.label).to eq 'Some Future Label'
        expect(QcResult.last.qc_assay_type.key).to eq 'some_future_key'
        expect(QcResult.last.value).to eq 'some future data'

        expect do
          factory.create_entities!
        end.to change(QcDecisionResult, :count).by(1)
      end
    end
  end

  describe 'QcResultMessage' do
    let(:qc_result)                     { create(:qc_result) }
    let(:qc_decision_long_read)         { create(:qc_decision, decision_made_by: :long_read) }
    let(:qc_decision_tol)               { create(:qc_decision, decision_made_by: :tol) }

    before do
      create(:qc_decision_result, qc_result:, qc_decision: qc_decision_long_read)
      create(:qc_decision_result, qc_result:, qc_decision: qc_decision_tol)
    end

    context 'long read' do
      let(:qc_result_message) { QcResultsUploadFactory::QcResultMessage.new(qc_result:, decision_made_by: qc_decision_long_read.decision_made_by) }

      it 'has the correct qc result data' do
        expect(qc_result_message.labware_barcode).to eq(qc_result.labware_barcode)
        expect(qc_result_message.sample_external_id).to eq(qc_result.sample_external_id)
        expect(qc_result_message.value).to eq(qc_result.value)
        expect(qc_result_message.qc_assay_type).to eq(qc_result.qc_assay_type)
      end

      it 'returns the correct decision' do
        expect(qc_result_message.qc_decision.decision_made_by).to eq(qc_decision_long_read.decision_made_by)
        expect(qc_result_message.qc_decision.status).to eq(qc_decision_long_read.status)
      end
    end

    context 'tol' do
      let(:qc_result_message) { QcResultsUploadFactory::QcResultMessage.new(qc_result:, decision_made_by: qc_decision_tol.decision_made_by) }

      it 'has the correct qc result data' do
        expect(qc_result_message.labware_barcode).to eq(qc_result.labware_barcode)
        expect(qc_result_message.sample_external_id).to eq(qc_result.sample_external_id)
        expect(qc_result_message.value).to eq(qc_result.value)
        expect(qc_result_message.qc_assay_type).to eq(qc_result.qc_assay_type)
      end

      it 'returns the correct decision' do
        expect(qc_result_message.qc_decision.decision_made_by).to eq(qc_decision_tol.decision_made_by)
        expect(qc_result_message.qc_decision.status).to eq(qc_decision_tol.status)
      end
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
      expect(factory.pivot_csv_data_to_obj[0]['average_fragment_size']).to eq 22688
      expect(factory.pivot_csv_data_to_obj[0]['results_pdf']).to eq 'Extraction.Femto.9764-9765'
    end
  end
end

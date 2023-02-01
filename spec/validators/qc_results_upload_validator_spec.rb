# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QcResultsUploadValidator do
  describe '#validate' do
    let(:required_headers) do
      [
        { name: 'LR EXTRACTION DECISION [ESP1]', require_value: true },
        { name: 'TOL DECISION [ESP1]', require_value: false },
        { name: 'Tissue Tube ID', require_value: true },
        { name: 'Sanger sample ID', require_value: true }
      ]
    end

    let(:record) { build(:qc_results_upload_factory) }

    before do
      create(:qc_assay_type, key: 'qubit_concentration_ngul', label: 'Qubit DNA Quant (ng/ul) [ESP1]', used_by: 0)
      create(:qc_assay_type, key: 'volume_si', label: 'DNA vol (ul)', used_by: 0)
      create(:qc_assay_type, key: '_260_230_ratio', label: 'ND 260/230 [ESP1]', used_by: 0)
    end

    context 'valid' do
      before do
        described_class.new({ required_headers: }).validate(record)
      end

      it 'does not add an error to the record' do
        expect(record).to be_valid
      end
    end

    describe '#validate_used_by' do
      describe 'when used_by is nil' do
        let(:qc_results_upload) { build(:qc_results_upload, used_by: nil) }
        let(:record) { build(:qc_results_upload_factory, qc_results_upload:) }

        it 'will mark the record as invalid' do
          described_class.new({ required_headers: }).validate(record)
          expect(record).not_to be_valid
          expect(record.errors.messages[:used_by]).to eq ["can't be blank"]
        end
      end

      describe 'when used_by does not match QcAssayTypes' do
        let(:qc_results_upload) { build(:qc_results_upload, used_by: 'unknown') }
        let(:record) { build(:qc_results_upload_factory, qc_results_upload:) }

        it 'will mark the record as invalid' do
          described_class.new({ required_headers: }).validate(record)
          expect(record).not_to be_valid
          expect(record.errors.messages[:used_by]).to eq ['No QcAssayTypes belong to used_by value']
        end
      end
    end

    describe '#validate_csv_data' do
      describe 'when csv_data is nil' do
        let(:qc_results_upload) { build(:qc_results_upload, csv_data: nil) }
        let(:record) { build(:qc_results_upload_factory, qc_results_upload:) }

        it 'will mark the record as invalid' do
          described_class.new({ required_headers: }).validate(record)
          expect(record).not_to be_valid
          expect(record.errors.messages[:csv_data]).to eq ["can't be blank"]
        end
      end
    end

    describe '#validate_rows' do
      describe 'when csv_data is empty' do
        let(:qc_results_upload) { build(:qc_results_upload, csv_data: 'line one \n') }
        let(:record) { build(:qc_results_upload_factory, qc_results_upload:) }

        it 'will mark the record as invalid' do
          described_class.new({ required_headers: }).validate(record)
          expect(record).not_to be_valid
          expect(record.errors.messages[:csv_data]).to eq ['Missing header row']
        end
      end

      describe 'when data is missing' do
        let(:csv_dupl_headers) do
          ",,SAMPLE INFORMATION,,,,,,,,,,,,,VOUCHERING,,,,EXTRACTION/QC,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,COLUMN JUST FOR TOL,COLUMN JUST FOR TOL,SE LIMS,
          Batch ,Tissue Tube ID,Sanger sample ID,Species,Genome Size,Tissue FluidX rack ID,Rack well location,Date,Crush Method,Tissue Mass (mg),Tissue type,Lysis ,DNA tube ID,DNAext FluidX Rack ID,Rack position,Voucher?,Voucher Tube ID,Voucher Rack ID,Sample Location,Qubit DNA Quant (ng/ul) [ESP1],DNA vol (ul),DNA total ng [ESP1],Femto dilution [ESP1],ND 260/280 [ESP1],ND 260/230 [ESP1],ND Quant (ng/ul) [ESP1],Femto Frag Size [ESP1],GQN >30000 [ESP1],Femto pdf [ESP1],LR EXTRACTION DECISION [ESP1],Sample Well Position in Plate,TOL DECISION [ESP1],DNA Fluid+ MR kit for viscous DNA?,MR Machine ID,MR speed,Vol Input DNA MR3 (uL),Save 1uL post shear,Vol Input SPRI (uL),SPRI volume (x0.6),Qubit Quant (ng/ul) [ESP2],Final Elution Volume (ul),Total DNA ng [ESP2],Femto Dil (ul) [ESP2],ND 260/280 [ESP2],ND 260/230 [ESP2],ND Quant (ng/uL) [ESP2],% DNA Recovery,Femto Fragment size [ESP2],GQN 10kb threshold [ESP2],Femto pdf [ESP2],LR SHEARING DECISION [ESP2],TOL DECISION [ESP2],ToL ID ,Genome size (TOL),SE Number,Date in PB Lab (Auto)"
        end
        let(:qc_results_upload) { build(:qc_results_upload, csv_data: csv_dupl_headers) }
        let(:record) { build(:qc_results_upload_factory, qc_results_upload:) }

        it 'will mark the record as invalid' do
          described_class.new({ required_headers: }).validate(record)
          expect(record).not_to be_valid
          expect(record.errors.messages[:csv_data]).to eq ['Missing data rows']
        end
      end
    end

    describe '#validate_headers' do
      describe 'when csv_data contains duplicate headers' do
        let(:csv_dupl_headers) do
          ",,SAMPLE INFORMATION,,,,,,,,,,,,,VOUCHERING,,,,EXTRACTION/QC,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,COLUMN JUST FOR TOL,COLUMN JUST FOR TOL,SE LIMS,
          Batch ,Tissue Tube ID,Tissue Tube ID,Species,Genome Size,Tissue FluidX rack ID,Rack well location,Date,Crush Method,Tissue Mass (mg),Tissue type,Lysis ,DNA tube ID,DNAext FluidX Rack ID,Rack position,Voucher?,Voucher Tube ID,Voucher Rack ID,Sample Location,Qubit DNA Quant (ng/ul) [ESP1],DNA vol (ul),DNA total ng [ESP1],Femto dilution [ESP1],ND 260/280 [ESP1],ND 260/230 [ESP1],ND Quant (ng/ul) [ESP1],Femto Frag Size [ESP1],GQN >30000 [ESP1],Femto pdf [ESP1],LR EXTRACTION DECISION [ESP1],Sample Well Position in Plate,TOL DECISION [ESP1],DNA Fluid+ MR kit for viscous DNA?,MR Machine ID,MR speed,Vol Input DNA MR3 (uL),Save 1uL post shear,Vol Input SPRI (uL),SPRI volume (x0.6),Qubit Quant (ng/ul) [ESP2],Final Elution Volume (ul),Total DNA ng [ESP2],Femto Dil (ul) [ESP2],ND 260/280 [ESP2],ND 260/230 [ESP2],ND Quant (ng/uL) [ESP2],% DNA Recovery,Femto Fragment size [ESP2],GQN 10kb threshold [ESP2],Femto pdf [ESP2],LR SHEARING DECISION [ESP2],TOL DECISION [ESP2],ToL ID ,Genome size (TOL),SE Number,Date in PB Lab (Auto)
          Production 1,FD20709764,DTOL12932860,,0.53,,,04/05/2022,Powermash,7.8,Non-plant,2h@25C,,,NA,Yes,FD38542652,SA00930879,A1,4.78,385,1840.3,18.12,2.38,0.57,14.9,22688,1.5,Extraction.Femto.9764-9765,Pass,,,,Alan Shearer/Britney Shears,30,,FALSE,,,22.6,45.4,1026.04,89.4,1.92,1.79,33.7,55.8,9772,4.4,Sheared.Femto.9764-6843,Pass,,idCheUrba1,0.52725,SE293337P,24/06/2022"
        end
        let(:qc_results_upload) { build(:qc_results_upload, csv_data: csv_dupl_headers) }
        let(:record) { build(:qc_results_upload_factory, qc_results_upload:) }

        it 'will mark the record as invalid' do
          described_class.new({ required_headers: }).validate(record)
          expect(record).not_to be_valid
          expect(record.errors.messages[:csv_data]).to eq ['Contains duplicated headers']
        end
      end
    end

    describe '#validate_fields' do
      describe 'when required headers are missing' do
        let(:csv_dupl_headers) do
          ",,SAMPLE INFORMATION,,,,,,,,,,,,,VOUCHERING,,,,EXTRACTION/QC,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,COLUMN JUST FOR TOL,COLUMN JUST FOR TOL,SE LIMS,
          Batch ,,,Species,Genome Size,Tissue FluidX rack ID,Rack well location,Date,Crush Method,Tissue Mass (mg),Tissue type,Lysis ,DNA tube ID,DNAext FluidX Rack ID,Rack position,Voucher?,Voucher Tube ID,Voucher Rack ID,Sample Location,Qubit DNA Quant (ng/ul) [ESP1],DNA vol (ul),DNA total ng [ESP1],Femto dilution [ESP1],ND 260/280 [ESP1],ND 260/230 [ESP1],ND Quant (ng/ul) [ESP1],Femto Frag Size [ESP1],GQN >30000 [ESP1],Femto pdf [ESP1],LR EXTRACTION DECISION [ESP1],Sample Well Position in Plate,TOL DECISION [ESP1],DNA Fluid+ MR kit for viscous DNA?,MR Machine ID,MR speed,Vol Input DNA MR3 (uL),Save 1uL post shear,Vol Input SPRI (uL),SPRI volume (x0.6),Qubit Quant (ng/ul) [ESP2],Final Elution Volume (ul),Total DNA ng [ESP2],Femto Dil (ul) [ESP2],ND 260/280 [ESP2],ND 260/230 [ESP2],ND Quant (ng/uL) [ESP2],% DNA Recovery,Femto Fragment size [ESP2],GQN 10kb threshold [ESP2],Femto pdf [ESP2],LR SHEARING DECISION [ESP2],TOL DECISION [ESP2],ToL ID ,Genome size (TOL),SE Number,Date in PB Lab (Auto)
          Production 1,FD20709764,DTOL12932860,,0.53,,,04/05/2022,Powermash,7.8,Non-plant,2h@25C,,,NA,Yes,FD38542652,SA00930879,A1,4.78,385,1840.3,18.12,2.38,0.57,14.9,22688,1.5,Extraction.Femto.9764-9765,Pass,,,,Alan Shearer/Britney Shears,30,,FALSE,,,22.6,45.4,1026.04,89.4,1.92,1.79,33.7,55.8,9772,4.4,Sheared.Femto.9764-6843,Pass,,idCheUrba1,0.52725,SE293337P,24/06/2022"
        end
        let(:qc_results_upload) { build(:qc_results_upload, csv_data: csv_dupl_headers) }
        let(:record) { build(:qc_results_upload_factory, qc_results_upload:) }

        it 'will mark the record as invalid' do
          described_class.new({ required_headers: }).validate(record)
          expect(record).not_to be_valid
          expect(record.errors.messages[:csv_data]).to eq ['Missing required headers: Tissue Tube ID,Sanger sample ID']
        end
      end
    end
  end
end

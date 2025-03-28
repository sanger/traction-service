# frozen_string_literal: true

require 'rails_helper'

# Oh. So we have a parser to test the sample sheets
# And then we have tests to test the parser to test the sample sheets
RSpec.describe Parsers::PacbioSampleSheetParser, type: :model do
  let(:sample_sheet_parser) { described_class.new }
  # and we also have a fixture
  let(:sample_sheet_string) { File.read('spec/fixtures/sample_sheet_revio_pacbio.csv') }

  describe '#split_into_sections' do
    subject(:split_sections) { sample_sheet_parser.split_into_sections(sample_sheet_string) }

    it 'returns a hash with three sections' do
      expect(split_sections.keys).to contain_exactly('Run Settings', 'SMRT Cell Settings', 'Samples')
    end

    context 'returns a hash with the correct content for each section' do
      it 'parses the Run Settings section correctly' do
        expect(split_sections['Run Settings']).to start_with("Instrument Type,Revio\nRun Name,Example Run\nRun Comments,")
        expect(split_sections['Run Settings']).to end_with('CSV Version,1')
      end

      it 'parses the SMRT Cell Settings section correctly' do
        # SMRT Cell Settings
        # the content should be in the form of a hash of hashes, one for each SMRT cell
        # the hash should contain key-value pairs for each SMRT cell setting, zipped from the row data
        expect(split_sections['SMRT Cell Settings']).to start_with(
          ",1_A01,1_B01,2_A01\nWell Name,Sample1_CCS,Sample2_CCS_BC,Sample3_CCS_basic"
        )
        expect(split_sections['SMRT Cell Settings']).to end_with(
          'Consensus Mode,molecule,molecule,molecule'
        )
      end

      it 'parses the Samples section correctly' do
        # Sample Settings
        # the content should be parsed by the built-in CSV parser and presented accordingly
        expect(split_sections['Samples']).to start_with(
          'Bio Sample Name,Plate Well,Adapter,Adapter2,Pipeline Id,Analysis Name,Entry Points,Task Options'
        )
        expect(split_sections['Samples']).to end_with(
          'lambda1,2_A01,bc2001,bc2001'
        )
      end
    end
  end

  describe '#parse_run_settings' do
    subject(:parsed_run_settings) { sample_sheet_parser.parse_run_settings(run_settings_string) }

    let(:run_settings_string) do
      <<~RUN_SETTINGS
        Instrument Type,Revio
        Run Name,Example Run
        Run Comments,Example Run comment
        Plate 1,102118800
        Plate 2,102118800
        CSV Version,1
      RUN_SETTINGS
    end

    it 'returns a hash with the correct key-value pairs' do
      expect(parsed_run_settings).to eq(
        {
          'Instrument Type' => 'Revio',
          'Run Name' => 'Example Run',
          'Run Comments' => 'Example Run comment',
          'Plate 1' => '102118800',
          'Plate 2' => '102118800',
          'CSV Version' => '1'
        }
      )
    end
  end

  describe '#parse_smrt_cell_settings' do
    subject(:parsed_smrt_cell_settings) { sample_sheet_parser.parse_smrt_cell_settings(smrt_cell_settings_string) }

    context 'when there is an inconsistent number of values for a key' do
      let(:smrt_cell_settings_string) do
        ",1_A01,1_B01,2_A01\n" \
          "Attribute,Value\n"
      end

      it 'raises an error' do
        expect { parsed_smrt_cell_settings }.to raise_error(RuntimeError, "Invalid number of values for key 'Attribute', expected 3, got 1")
      end
    end
  end

  describe '#parse_sample_sheet' do
    subject(:parsed_sample_sheet) { sample_sheet_parser.parse(sample_sheet_string) }

    it 'returns a hash with three sections' do
      expect(parsed_sample_sheet.keys).to contain_exactly('Run Settings', 'SMRT Cell Settings', 'Samples')
    end

    context 'returns a hash with the correct content for each section' do
      it 'parses the Run Settings section correctly' do
        # Run Settings
        # the content should be in the form of a hash of key-value pairs
        expect(parsed_sample_sheet['Run Settings']).to eq(
          {
            'Instrument Type' => 'Revio',
            'Run Name' => 'Example Run',
            'Run Comments' => 'Example Run comment',
            'Plate 1' => '102118800',
            'Plate 2' => '102118800',
            'CSV Version' => '1'
          }
        )
      end

      it 'parses the SMRT Cell Settings section correctly' do
        # SMRT Cell Settings
        # the content should be in the form of a hash of hashes, one for each SMRT cell
        # the hash should contain key-value pairs for each SMRT cell setting, zipped from the row data
        expect(parsed_sample_sheet['SMRT Cell Settings'].keys).to contain_exactly('1_A01', '1_B01', '2_A01')
        expect(parsed_sample_sheet['SMRT Cell Settings']['1_A01']).to include(
          'Well Name' => 'Sample1_CCS',
          'Well Comment' => 'Sample 1 comment',
          'Application' => 'HiFi Reads',
          'Library Type' => 'Standard',
          'Movie Acquisition Time (hours)' => '24',
          'Insert Size (bp)' => '2000',
          'Assign Data To Project' => '1',
          'Library Concentration (pM)' => '7',
          'Include Base Kinetics' => false
        )

        expect(parsed_sample_sheet['SMRT Cell Settings']['1_B01']).to include(
          'Well Name' => 'Sample2_CCS_BC',
          'Well Comment' => 'Sample 2 comment',
          'Application' => 'HiFi Reads',
          'Library Type' => 'Standard',
          'Movie Acquisition Time (hours)' => '24',
          'Insert Size (bp)' => '2000',
          'Assign Data To Project' => '1',
          'Library Concentration (pM)' => '7',
          'Include Base Kinetics' => false
        )

        expect(parsed_sample_sheet['SMRT Cell Settings']['2_A01']).to include(
          'Well Name' => 'Sample3_CCS_basic',
          'Well Comment' => 'Sample 3 comment',
          'Application' => 'Unspecified',
          'Library Type' => 'Standard',
          'Movie Acquisition Time (hours)' => '24',
          'Insert Size (bp)' => '2000',
          'Assign Data To Project' => '1',
          'Library Concentration (pM)' => '7',
          'Include Base Kinetics' => false
        )
      end

      it 'parses the Samples section correctly' do
        # Sample Settings
        # the content should be parsed by the built-in CSV parser and presented accordingly

        # Bio Sample Name,Plate Well,Adapter,Adapter2,Pipeline Id,Analysis Name,Entry Points,Task Options
        # lambda1,1_A01,bc2001,bc2001
        # lambda1,1_B01,lbc1,lbc1,cromwell.workflows.dev_mock_analysis,lambda1analysis,PacBio.DataSet.ReferenceSet;eid_ref_dataset;1a369917-507e-4f70-9f38-69614ff828b6,param_a;boolean;false|param_c;integer;16|param_d;float;0.99
        # lambda2,1_B01,lbc2,lbc2,cromwell.workflows.dev_mock_analysis,lambda2analysis,PacBio.DataSet.ReferenceSet;eid_ref_dataset;1a369917-507e-4f70-9f38-69614ff828b6,param_a;boolean;false|param_c;integer;25|param_d;float;0.99
        # lambda3,1_B01,lbc3,lbc3,cromwell.workflows.dev_mock_analysis,lambda3analysis,PacBio.DataSet.ReferenceSet;eid_ref_dataset;1a369917-507e-4f70-9f38-69614ff828b6,param_a;boolean;false|param_c;integer;36|param_d;float;0.99
        # lambda1,2_A01,bc2001,bc2001
        expect(parsed_sample_sheet['Samples']).to eq([
          {
            'Bio Sample Name' => 'lambda1',
            'Plate Well' => '1_A01',
            'Adapter' => 'bc2001',
            'Adapter2' => 'bc2001',
            'Pipeline Id' => nil,
            'Analysis Name' => nil,
            'Entry Points' => nil,
            'Task Options' => nil
          },
          {
            'Bio Sample Name' => 'lambda1',
            'Plate Well' => '1_B01',
            'Adapter' => 'lbc1',
            'Adapter2' => 'lbc1',
            'Pipeline Id' => 'cromwell.workflows.dev_mock_analysis',
            'Analysis Name' => 'lambda1analysis',
            'Entry Points' => 'PacBio.DataSet.ReferenceSet;eid_ref_dataset;1a369917-507e-4f70-9f38-69614ff828b6',
            'Task Options' => 'param_a;boolean;false|param_c;integer;16|param_d;float;0.99'
          },
          {
            'Bio Sample Name' => 'lambda2',
            'Plate Well' => '1_B01',
            'Adapter' => 'lbc2',
            'Adapter2' => 'lbc2',
            'Pipeline Id' => 'cromwell.workflows.dev_mock_analysis',
            'Analysis Name' => 'lambda2analysis',
            'Entry Points' => 'PacBio.DataSet.ReferenceSet;eid_ref_dataset;1a369917-507e-4f70-9f38-69614ff828b6',
            'Task Options' => 'param_a;boolean;false|param_c;integer;25|param_d;float;0.99'
          },
          {
            'Bio Sample Name' => 'lambda3',
            'Plate Well' => '1_B01',
            'Adapter' => 'lbc3',
            'Adapter2' => 'lbc3',
            'Pipeline Id' => 'cromwell.workflows.dev_mock_analysis',
            'Analysis Name' => 'lambda3analysis',
            'Entry Points' => 'PacBio.DataSet.ReferenceSet;eid_ref_dataset;1a369917-507e-4f70-9f38-69614ff828b6',
            'Task Options' => 'param_a;boolean;false|param_c;integer;36|param_d;float;0.99'
          },
          {
            'Bio Sample Name' => 'lambda1',
            'Plate Well' => '2_A01',
            'Adapter' => 'bc2001',
            'Adapter2' => 'bc2001',
            'Pipeline Id' => nil,
            'Analysis Name' => nil,
            'Entry Points' => nil,
            'Task Options' => nil
          }
        ])
      end
    end
  end
end

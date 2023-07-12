# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PacbioSampleSheetV12Revio do
  before { create(:pacbio_smrt_link_version, name: 'v12', default: true) }

  context "when the tagging doesn't matter" do
    let!(:sample_sheet_compiler) { described_class.new(nil) } # empty run, we are only interested in the headers

    it 'generates the header for the version' do
      headers = sample_sheet_compiler.generate_headers
      expect(headers).to eql([
        'Library Type',
        'Reagent Plate',
        'Plate 1',
        'Plate 2',
        'Run Name',
        'Instrument Type',
        'Run Comments',
        'Is Collection',
        'Sample Well',
        'Well Name',
        'Movie Acquisition Time (hours)',
        'Include Base Kinetics',
        'Library Concentration (pM)',
        'Polymerase Kit',
        'Automation Parameters',
        'Adapters / Barcodes',
        'Barcode Name',
        'Bio Sample Name'
      ])
    end
  end

  context 'when the libraries are tagged' do
    let!(:well1) do
      create(:pacbio_well_with_pools, pre_extension_time: 2, generate_hifi: 'In SMRT Link',
                                      ccs_analysis_output: 'Yes')
    end
    let!(:well2) do
      create(:pacbio_well_with_pools, pre_extension_time: 2, generate_hifi: 'In SMRT Link',
                                      ccs_analysis_output: 'No')
    end
    let(:plate) { create(:pacbio_plate, wells: [well1, well2]) }
    let!(:run) { create(:pacbio_run, plates: [plate]) }
    let!(:sample_sheet_compiler) { described_class.new(run:) }

    it 'returns the row array based on the column config' do
      args = {
        context: :library,
        run:,
        plate:,
        well: well1,
        library: well1.libraries.first
      }

      row = sample_sheet_compiler.generate_row(args)

      expect(row).to eq([
        '',
        '1',
        '',
        '',
        run.name,
        'Sequel IIe',
        'A Run Comment',
        true,
        well1.position_leading_zero,
        well1.pool_barcode,
        15,
        'True',
        well1.library_concentration,
        well1.polymerase_kit,
        'ExtensionTime=double:2|ExtendFirst=boolean:True',
        well1.barcode_set,
        well1.libraries.first.barcode_name,
        ''
      ])
    end
  end

  context 'when the libraries are untagged' do
    let(:pool1)   { create_list(:pacbio_pool, 1, :untagged) }
    let(:pool2)   { create_list(:pacbio_pool, 1, :untagged) }
    let(:well1)   do
      create(:pacbio_well, pre_extension_time: 2, generate_hifi: 'Do Not Generate',
                           ccs_analysis_output: 'Yes', pools: pool1)
    end
    let(:well2) do
      create(:pacbio_well, generate_hifi: 'On Instrument', ccs_analysis_output: 'No',
                           pools: pool2)
    end
    let(:plate) { create(:pacbio_plate, wells: [well1, well2]) }
    let!(:run) { create(:pacbio_run, plates: [plate]) }
    let!(:sample_sheet_compiler) { described_class.new(run:) }

    it 'returns the row array based on the column config' do
      args = {
        context: :well,
        run:,
        plate:,
        well: well1
        #  note the lack of `library`
      }

      row = sample_sheet_compiler.generate_row(args)

      expect(row).to eq([
        'Revio',
        '1',
        '',
        '',
        run.name,
        'Sequel IIe',
        'A Run Comment',
        true,
        well1.position_leading_zero,
        well1.pool_barcode,
        15,
        'True',
        well1.library_concentration,
        well1.polymerase_kit,
        'ExtensionTime=double:2|ExtendFirst=boolean:True',
        '',
        '',
        well1.find_sample_name
      ])
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

# See additional sample sheet specs at 'spec/exchanges/run_csv/pacbio_sample_sheet_spec.rb'

RSpec.describe 'SampleSheet', type: :model do
  let(:populate) { { for: [:well], with: :well }.with_indifferent_access }
  let(:populate_with_sample) { { for: %i[well sample], with: :well }.with_indifferent_access }

  context 'v11' do
    let(:sample_sheet_configuration) { Pipelines.pacbio.sample_sheet.by_version('v11') }

    it 'must have CCS Analysis Output - Include Low Quality Reads' do
      column = sample_sheet_configuration.columns.children['CCS Analysis Output - Include Low Quality Reads']
      expect(column).to be_present
      expect(column.fetch('type')).to eq(:model)
      expect(column.fetch('value')).to eq('ccs_analysis_output_include_low_quality_reads')
      expect(column.fetch('populate')).to eq(populate)
    end

    it 'must have Include 5mC Calls in CpG Motifs' do
      column = sample_sheet_configuration.columns.children['Include 5mC Calls in CpG Motifs']
      expect(column).to be_present
      expect(column.fetch('type')).to eq(:model)
      expect(column.fetch('value')).to eq('include_fivemc_calls_in_cpg_motifs')
      expect(column.fetch('populate')).to eq(populate)
    end

    it 'does not have generate hi fi' do
      expect(sample_sheet_configuration.columns.children).not_to have_key('Generate HiFi Reads')
    end

    it 'has demultiplex barcodes' do
      column = sample_sheet_configuration.columns.children['Demultiplex Barcodes']
      expect(column).to be_present
      expect(column.fetch('type')).to eq(:model)
      expect(column.fetch('value')).to eq('demultiplex_barcodes')
      expect(column.fetch('populate')).to eq(populate)
    end
  end
end

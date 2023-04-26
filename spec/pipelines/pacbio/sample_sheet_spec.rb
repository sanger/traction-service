# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SampleSheet', type: :model do
  let(:populate) { { for: [:well], with: :well }.with_indifferent_access }

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

    it 'will not have generate hi fi' do
      expect(sample_sheet_configuration.columns.children).not_to have_key('Generate HiFi Reads')
    end

    it 'will have demultiplex barcodes' do
      column = sample_sheet_configuration.columns.children['Demultiplex Barcodes']
      expect(column).to be_present
      expect(column.fetch('type')).to eq(:model)
      expect(column.fetch('value')).to eq('demultiplex_barcodes')
      expect(column.fetch('populate')).to eq(populate)
    end
  end

  context 'v12_revio' do
    let(:sample_sheet_configuration) { Pipelines.pacbio.sample_sheet.by_version('v12_revio') }

    it 'will have library type' do
      column = sample_sheet_configuration.columns.children['Library Type']
      expect(column).to be_present
      expect(column.fetch('type')).to eq(:string)
      expect(column.fetch('value')).to eq('Standard')
      expect(column.fetch('populate')).to eq(populate)
    end

    # Where should the rest of the sample sheet columns be tested?
    it 'will have movie acquisition time' do
      column = sample_sheet_configuration.columns.children['Movie Acquisition Time (hours)']
      expect(column).to be_present
      expect(column.fetch('type')).to eq(:model)
      expect(column.fetch('value')).to eq('movie_acquisition_time')
      expect(column.fetch('populate')).to eq(populate)
    end

    it 'may have include base kinetics' do
      column = sample_sheet_configuration.columns.children['Include Base Kinetics']
      expect(column).to be_present
      expect(column.fetch('type')).to eq(:model)
      expect(column.fetch('value')).to eq('include_base_kinetics')
      expect(column.fetch('populate')).to eq(populate)
    end

    it 'may have library concentration (pM)' do
      column = sample_sheet_configuration.columns.children['Library Concentration (pM)']
      expect(column).to be_present
      expect(column.fetch('type')).to eq(:model)
      expect(column.fetch('value')).to eq('library_concentration')
      expect(column.fetch('populate')).to eq(populate)
    end

    it 'will have polymerase kit' do
      column = sample_sheet_configuration.columns.children['Polymerase Kit']
      expect(column).to be_present
      expect(column.fetch('type')).to eq(:model)
      expect(column.fetch('value')).to eq('polymerase_kit')
      expect(column.fetch('populate')).to eq(populate)
    end
  end
end

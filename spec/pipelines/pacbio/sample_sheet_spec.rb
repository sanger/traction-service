# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SampleSheet', type: :model do
  context 'v11' do
    let(:sample_sheet_configuration) { Pipelines.pacbio.sample_sheet.by_version('v11') }

    it 'must have CCS Analysis Output - Include Low Quality Reads' do
      column = sample_sheet_configuration.columns.children['CCS Analysis Output - Include Low Quality Reads']
      expect(column).to be_present
      expect(column.fetch('type')).to eq(:string)
      expect(column.fetch('value')).to be(true)
    end

    it 'must have 5mC Calls in CpG Motifs' do
      column = sample_sheet_configuration.columns.children['5mC Calls in CpG Motifs']
      expect(column).to be_present
      expect(column.fetch('type')).to eq(:string)
      expect(column.fetch('value')).to be(true)
    end
  end
end

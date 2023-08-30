# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RunCsv::OntSampleSheet, type: :model do
  before do
    create(:ont_min_know_version, name: 'v22', default: true)
  end

  describe '#generate' do
    subject(:csv_string) { csv.generate }

    let(:run) { create(:ont_run, flowcell_count: 2) }
    let(:parsed_csv) { CSV.parse(csv_string) }
    let(:configuration) { Pipelines.ont.sample_sheet.by_version(run.min_know_version.name) }
    let(:csv) { described_class.new(run:, configuration:) }

    it 'must return a csv string' do
      expect(csv_string.class).to eq String
    end

    it 'must have the correct headers' do
      headers = parsed_csv[0]

      expected_headers = configuration.columns.map(&:first)
      expect(headers).to eq(expected_headers)
    end

    it 'must have the correct sample rows' do
      sample_data_1 = parsed_csv[1]
      sample_data_2 = parsed_csv[2]

      expect(sample_data_1).to eq([
        run.flowcells[0].flowcell_id,
        run.flowcells[0].pool.kit_barcode,
        run.flowcells[0].pool.tube.barcode,
        run.experiment_name,
        run.flowcells[0].pool.libraries.first.tag.group_id,
        run.flowcells[0].pool.libraries.first.sample.name,
        run.flowcells[0].pool.libraries.first.request.data_type.name
      ])

      expect(sample_data_2).to eq([
        run.flowcells[1].flowcell_id,
        run.flowcells[1].pool.kit_barcode,
        run.flowcells[1].pool.tube.barcode,
        run.experiment_name,
        run.flowcells[1].pool.libraries.first.tag.group_id,
        run.flowcells[1].pool.libraries.first.sample.name,
        run.flowcells[1].pool.libraries.first.request.data_type.name
      ])
    end
  end
end

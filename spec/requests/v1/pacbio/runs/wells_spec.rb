# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'WellsController' do
  before do
    create(:pacbio_smrt_link_version, name: 'v10', default: true)
    create(:pacbio_smrt_link_version, name: 'v11')
  end

  describe '#get' do
    let!(:wells) { create_list(:pacbio_well_with_pools, 2, pool_count: 2) }

    it 'returns a list of wells' do
      get v1_pacbio_runs_wells_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      get "#{v1_pacbio_runs_wells_path}?include=pools", headers: json_api_headers

      expect(response).to have_http_status(:success), response.body
      well = wells.first
      well_attributes = json['data'][0]['attributes']
      expect(well_attributes['pacbio_plate_id']).to eq(well.pacbio_plate_id)
      expect(well_attributes['row']).to eq(well.row)
      expect(well_attributes['column']).to eq(well.column)
      expect(well_attributes['movie_time'].to_s).to eq(well.movie_time.to_s)
      expect(well_attributes['on_plate_loading_concentration']).to eq(well.on_plate_loading_concentration)
      expect(well_attributes['pacbio_plate_id']).to eq(well.pacbio_plate_id)
      expect(well_attributes['comment']).to eq(well.comment)
      expect(well_attributes['pre_extension_time']).to eq(well.pre_extension_time)
      expect(well_attributes['binding_kit_box_barcode']).to eq(well.binding_kit_box_barcode)

      # v10
      expect(well_attributes['generate_hifi']).to eq(well.generate_hifi)
      expect(well_attributes['ccs_analysis_output']).to eq(well.ccs_analysis_output)

      # v11
      expect(well_attributes['ccs_analysis_output_include_low_quality_reads']).to eq(well.ccs_analysis_output_include_low_quality_reads)
      expect(well_attributes['include_fivemc_calls_in_cpg_motifs']).to eq(well.include_fivemc_calls_in_cpg_motifs)
      expect(well_attributes['ccs_analysis_output_include_kinetics_information']).to eq(well.ccs_analysis_output_include_kinetics_information)
      expect(well_attributes['demultiplex_barcodes']).to eq(well.demultiplex_barcodes)
    end
  end
end

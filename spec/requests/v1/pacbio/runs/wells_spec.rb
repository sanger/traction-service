# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'WellsController' do
  before do
    create(:pacbio_smrt_link_version, name: 'v10', default: true)
    create(:pacbio_smrt_link_version, name: 'v11')
    create(:pacbio_smrt_link_version, name: 'v12_revio')
  end

  describe '#get' do
    let!(:wells) { create_list(:pacbio_well, 2, pool_count: 2, annotation_count: 1) }

    it 'returns a list of wells' do
      get v1_pacbio_runs_wells_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      expect(json['data'].length).to eq(2)
    end

    describe 'has the correct attributes' do
      before do
        get "#{v1_pacbio_runs_wells_path}?include=pools,used_aliquots,annotations", headers: json_api_headers
      end

      let!(:well) { wells.first }
      let!(:well_attributes) { json['data'][0]['attributes'] }

      it 'has the correct standard attributes' do
        expect(response).to have_http_status(:success), response.body
        expect(well_attributes['pacbio_plate_id']).to eq(well.pacbio_plate_id)
        expect(well_attributes['row']).to eq(well.row)
        expect(well_attributes['column']).to eq(well.column)
        expect(well_attributes['movie_time'].to_s).to eq(well.movie_time.to_s)
        expect(well_attributes['on_plate_loading_concentration']).to eq(well.on_plate_loading_concentration)
        expect(well_attributes['pacbio_plate_id']).to eq(well.pacbio_plate_id)
        expect(well_attributes['pre_extension_time']).to eq(well.pre_extension_time)
        expect(well_attributes['binding_kit_box_barcode']).to eq(well.binding_kit_box_barcode)
      end

      it 'has the correct included data' do
        wells.collect(&:pools).flatten.each do |pool|
          pools_attributes = find_included_resource(type: 'pools', id: pool.id)['attributes']
          expect(pools_attributes).to include(
            'concentration' => pool.concentration,
            'volume' => pool.volume,
            'template_prep_kit_box_barcode' => pool.template_prep_kit_box_barcode,
            'insert_size' => pool.insert_size,
            'created_at' => pool.created_at.to_fs(:us)
          )
        end

        wells.collect(&:used_aliquots).flatten.each do |aliquot|
          aliquot_attributes = find_included_resource(type: 'aliquots', id: aliquot.id)['attributes']
          expect(aliquot_attributes).to include(
            'volume' => aliquot.volume,
            'concentration' => aliquot.concentration,
            'aliquot_type' => aliquot.aliquot_type
          )
        end

        annotation_attributes = find_included_resource(type: 'annotations', id: well.annotations.first.id)['attributes']
        expect(annotation_attributes).to include(
          'comment' => well.annotations.first.comment,
          'user' => well.annotations.first.user,
          'created_at' => well.annotations.first.created_at.to_fs(:us),
          'annotation_type_id' => well.annotations.first.annotation_type_id,
          'annotatable_type' => well.annotations.first.annotatable_type,
          'annotatable_id' => well.annotations.first.annotatable_id
        )
      end

      it 'has the correct v10 attributes' do
        expect(well_attributes['generate_hifi']).to eq(well.generate_hifi)
        expect(well_attributes['ccs_analysis_output']).to eq(well.ccs_analysis_output)
      end

      it 'has the correct v11 attributes' do
        expect(well_attributes['ccs_analysis_output_include_low_quality_reads']).to eq(well.ccs_analysis_output_include_low_quality_reads)
        expect(well_attributes['include_fivemc_calls_in_cpg_motifs']).to eq(well.include_fivemc_calls_in_cpg_motifs)
        expect(well_attributes['ccs_analysis_output_include_kinetics_information']).to eq(well.ccs_analysis_output_include_kinetics_information)
        expect(well_attributes['demultiplex_barcodes']).to eq(well.demultiplex_barcodes)
      end

      it 'has the correct v12_revio attributes' do
        expect(well_attributes['movie_acquisition_time']).to eq(well.movie_acquisition_time)
        expect(well_attributes['include_base_kinetics']).to eq(well.include_base_kinetics)
        expect(well_attributes['library_concentration']).to eq(well.library_concentration)
        expect(well_attributes['polymerase_kit']).to eq(well.polymerase_kit)
      end
    end
  end
end

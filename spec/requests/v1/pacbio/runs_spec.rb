# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'RunsController' do
  # Create default and non-default smrt link versions for runs
  let!(:version10) { create(:pacbio_smrt_link_version, name: 'v10', default: true) }
  let!(:version11) { create(:pacbio_smrt_link_version, name: 'v11') }
  let!(:version12) { create(:pacbio_smrt_link_version, name: 'v12_revio') }

  shared_examples 'publish_messages_on_create' do
    it 'publishes a message' do
      expect(Messages).to receive(:publish).with(instance_of(Pacbio::Plate), having_attributes(pipeline: 'pacbio'))
      post v1_pacbio_runs_path, params: body, headers: json_api_headers
      expect(response).to have_http_status(:success), response.body
    end
  end

  shared_examples 'publish_messages_on_update' do
    it 'publishes a message' do
      expect(Messages).to receive(:publish).with(run.plate, having_attributes(pipeline: 'pacbio'))
      patch v1_pacbio_run_path(run), params: body, headers: json_api_headers
      expect(response).to have_http_status(:success), response.body
    end
  end

  describe '#get' do
    let!(:run1) { create(:pacbio_run, state: 'pending') }
    let!(:run2) { create(:pacbio_run, state: 'started') }
    let!(:plate1) { create(:pacbio_plate, run: run1, well_count: 1) }
    let!(:plate2) { create(:pacbio_plate, run: run2, well_count: 1) }

    it 'returns a list of runs' do
      get v1_pacbio_runs_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      get v1_pacbio_runs_path, headers: json_api_headers

      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'][0]['attributes']['name']).to eq(run1.name)
      expect(json['data'][0]['attributes']['sequencing_kit_box_barcode']).to eq(run1.sequencing_kit_box_barcode)
      expect(json['data'][0]['attributes']['dna_control_complex_box_barcode']).to eq(run1.dna_control_complex_box_barcode)
      expect(json['data'][0]['attributes']['system_name']).to eq(run1.system_name)
      expect(json['data'][0]['attributes']['created_at']).to eq(run1.created_at.to_fs(:us))
      expect(json['data'][0]['attributes']['state']).to eq(run1.state)
      expect(json['data'][0]['attributes']['comments']).to eq(run1.comments)
      expect(json['data'][1]['attributes']['name']).to eq(run2.name)
    end

    it 'returns the correct relationships', aggregate_failures: true do
      get "#{v1_pacbio_runs_path}?include=plate,smrt_link_version", headers: json_api_headers

      expect(response).to have_http_status(:success), response.body
      json = ActiveSupport::JSON.decode(response.body)

      plate1_attributes = find_included_resource(type: 'plates', id: plate1.id)['attributes']
      expect(plate1_attributes).to include(
        'pacbio_run_id' => run1.id
      )
      plate2_attributes = find_included_resource(type: 'plates', id: plate2.id)['attributes']
      expect(plate2_attributes).to include(
        'pacbio_run_id' => run2.id
      )

      expect(json['data'][0]['relationships']['smrt_link_version']).to be_present
      expect(json['data'][0]['relationships']['smrt_link_version']['data']['type']).to eq 'smrt_link_versions'
      expect(json['data'][0]['relationships']['smrt_link_version']['data']['id']).to eq run1.smrt_link_version.id.to_s
    end

    context 'pagination' do
      let!(:run1) { create(:pacbio_run, created_at: Time.zone.now) }
      let!(:run2) { create(:pacbio_run, created_at: Time.zone.now + 2000) }
      let!(:expected_runs) { [run1, run2] }

      before do
        # There should be 4 runs total so we should get the 2 we just created
        get "#{v1_pacbio_runs_path}?page[number]=1&page[size]=2",
            headers: json_api_headers
      end

      it 'has a success status' do
        expect(response).to have_http_status(:success), response.body
      end

      it 'returns a list of runs' do
        expect(json['data'].length).to eq(2)
      end

      it 'returned the most recent first' do
        expect(json['data'][0]['id'].to_i).to eq(run2.id)
        expect(json['data'][1]['id'].to_i).to eq(run1.id)
      end

      it 'returns the correct attributes', aggregate_failures: true do
        expected_runs.each do |run|
          get "#{v1_pacbio_runs_path}/#{run.id}", headers: json_api_headers

          expect(response).to have_http_status(:success), response.body
          json = ActiveSupport::JSON.decode(response.body)
          run_attributes = json['data']['attributes']

          expect(run_attributes).to include(
            'name' => run.name,
            'sequencing_kit_box_barcode' => run.sequencing_kit_box_barcode,
            'dna_control_complex_box_barcode' => run.dna_control_complex_box_barcode,
            'system_name' => run.system_name,
            'state' => run.state,
            'comments' => run.comments,
            'pacbio_smrt_link_version_id' => run.pacbio_smrt_link_version_id,
            'created_at' => run.created_at.to_fs(:us)
          )
        end
      end
    end

    context 'filter' do
      context 'name' do
        before do
          get "#{v1_pacbio_runs_path}?filter[name]=#{run1.name}",
              headers: json_api_headers
        end

        it 'has a success status' do
          expect(response).to have_http_status(:success), response.body
        end

        it 'returns a list of runs' do
          expect(json['data'].length).to eq(1)
        end

        it 'returns the correct attributes' do
          json = ActiveSupport::JSON.decode(response.body)
          run_attributes = json['data'][0]['attributes']

          expect(run_attributes).to include(
            'name' => run1.name,
            'sequencing_kit_box_barcode' => run1.sequencing_kit_box_barcode,
            'dna_control_complex_box_barcode' => run1.dna_control_complex_box_barcode,
            'system_name' => run1.system_name,
            'state' => run1.state,
            'comments' => run1.comments,
            'pacbio_smrt_link_version_id' => run1.pacbio_smrt_link_version_id,
            'created_at' => run1.created_at.to_fs(:us)
          )
        end
      end

      context 'state' do
        before do
          get "#{v1_pacbio_runs_path}?filter[state]=#{run1.state}",
              headers: json_api_headers
        end

        it 'has a success status' do
          expect(response).to have_http_status(:success), response.body
        end

        it 'returns a list of runs' do
          expect(json['data'].length).to eq(1)
        end

        it 'returns the correct attributes' do
          json = ActiveSupport::JSON.decode(response.body)
          run_attributes = json['data'][0]['attributes']

          expect(run_attributes).to include(
            'name' => run1.name,
            'sequencing_kit_box_barcode' => run1.sequencing_kit_box_barcode,
            'dna_control_complex_box_barcode' => run1.dna_control_complex_box_barcode,
            'system_name' => run1.system_name,
            'state' => run1.state,
            'comments' => run1.comments,
            'pacbio_smrt_link_version_id' => run1.pacbio_smrt_link_version_id,
            'created_at' => run1.created_at.to_fs(:us)
          )
        end
      end
    end
  end

  describe '#create' do
    context 'smrtlink v11 on success' do
      let(:pool1) { create(:pacbio_pool) }

      let(:body) do
        {
          data: {
            type: 'runs',
            attributes: {
              sequencing_kit_box_barcode: 'DM0001100861800123121',
              dna_control_complex_box_barcode: 'Lxxxxx101717600123191',
              system_name: 'Sequel II',
              comments: 'A Run Comment',
              pacbio_smrt_link_version_id: version11.id,
              well_attributes: [
                {
                  row: 'A',
                  column: '1',
                  movie_time: 31,
                  on_plate_loading_concentration: 8.35,
                  pre_extension_time: '2',
                  generate_hifi: 'In SMRT Link',
                  ccs_analysis_output: 'Yes',
                  binding_kit_box_barcode: 'DM1117100862200111711',
                  ccs_analysis_output_include_low_quality_reads: 'Yes',
                  include_fivemc_calls_in_cpg_motifs: 'Yes',
                  ccs_analysis_output_include_kinetics_information: 'Yes',
                  demultiplex_barcodes: 'In SMRT Link',
                  pools: [pool1.id]
                }
              ]
            }
          }
        }.to_json
      end

      it 'has a created status' do
        post v1_pacbio_runs_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created)
      end

      it 'creates a run' do
        expect { post v1_pacbio_runs_path, params: body, headers: json_api_headers }.to change(Pacbio::Run, :count).by(1)
      end

      it 'creates a plate' do
        expect { post v1_pacbio_runs_path, params: body, headers: json_api_headers }.to change(Pacbio::Plate, :count).by(1)
      end

      it 'creates a well' do
        expect { post v1_pacbio_runs_path, params: body, headers: json_api_headers }.to change(Pacbio::Well, :count).by(1)
      end

      it 'creates a well pool' do
        expect { post v1_pacbio_runs_path, params: body, headers: json_api_headers }.to change(Pacbio::WellPool, :count).by(1)
      end

      it 'creates a run with the correct attributes' do
        post v1_pacbio_runs_path, params: body, headers: json_api_headers
        json = ActiveSupport::JSON.decode(response.body)
        run = Pacbio::Run.first

        expect(run.id).to eq(json['data']['id'].to_i)
        expect(run.name).to be_present
        expect(run.state).to be_present
        expect(run.sequencing_kit_box_barcode).to be_present
        expect(run.dna_control_complex_box_barcode).to be_present
        expect(run.system_name).to be_present
        expect(run.comments).to be_present
        expect(run.smrt_link_version).to be_present
        expect(run.smrt_link_version).to eq(version11)
        expect(run.pacbio_smrt_link_version_id).to eq(version11.id)
      end

      it_behaves_like 'publish_messages_on_create'
    end

    context 'smrtlink v12_revio on success' do
      let(:pool1) { create(:pacbio_pool) }

      let(:body) do
        {
          data: {
            type: 'runs',
            attributes: {
              sequencing_kit_box_barcode: 'DM0001100861800123121',
              dna_control_complex_box_barcode: 'Lxxxxx101717600123191',
              system_name: 'Sequel II',
              comments: 'A Run Comment',
              pacbio_smrt_link_version_id: version12.id,
              well_attributes: [
                {
                  row: 'A',
                  column: '1',
                  movie_acquisition_time: 30,
                  library_concentration: 8.35,
                  pre_extension_time: '2',
                  include_base_kinetics: 'True',
                  polymerase_kit: 'ABC123',
                  pools: [pool1.id]
                }
              ]
            }
          }
        }.to_json
      end

      it 'has a created status' do
        post v1_pacbio_runs_path, params: body, headers: json_api_headers
        expect(response).to have_http_status(:created)
      end

      it 'creates a run' do
        expect { post v1_pacbio_runs_path, params: body, headers: json_api_headers }.to change(Pacbio::Run, :count).by(1)
      end

      it 'creates a plate' do
        expect { post v1_pacbio_runs_path, params: body, headers: json_api_headers }.to change(Pacbio::Plate, :count).by(1)
      end

      it 'creates a well' do
        expect { post v1_pacbio_runs_path, params: body, headers: json_api_headers }.to change(Pacbio::Well, :count).by(1)
      end

      it 'creates a well pool' do
        expect { post v1_pacbio_runs_path, params: body, headers: json_api_headers }.to change(Pacbio::WellPool, :count).by(1)
      end

      it 'creates a run with the correct attributes' do
        post v1_pacbio_runs_path, params: body, headers: json_api_headers
        json = ActiveSupport::JSON.decode(response.body)
        run = Pacbio::Run.first

        expect(run.id).to eq(json['data']['id'].to_i)
        expect(run.name).to be_present
        expect(run.state).to be_present
        expect(run.sequencing_kit_box_barcode).to be_present
        expect(run.dna_control_complex_box_barcode).to be_present
        expect(run.system_name).to be_present
        expect(run.comments).to be_present
        expect(run.smrt_link_version).to be_present
        expect(run.smrt_link_version).to eq(version12)
        expect(run.pacbio_smrt_link_version_id).to eq(version12.id)
      end

      it_behaves_like 'publish_messages_on_create'
    end

    context 'on failure' do
      context 'when there is missing run data' do
        # We send an empty request body.
        let(:body) do
          {
            data: {
              type: 'runs',
              attributes: {}
            }
          }.to_json
        end

        it 'has a unprocessable_entity status' do
          post v1_pacbio_runs_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not create a run' do
          expect do
            post v1_pacbio_runs_path, params: body,
                                      headers: json_api_headers
          end.not_to change(Pacbio::Run, :count)
        end

        it 'has the correct error messages' do
          post v1_pacbio_runs_path, params: body, headers: json_api_headers
          json = ActiveSupport::JSON.decode(response.body)
          errors = json['errors']
          expect(errors[0]['detail']).to eq "sequencing_kit_box_barcode - can't be blank"
          expect(errors[1]['detail']).to eq "dna_control_complex_box_barcode - can't be blank"
        end
      end

      context 'when there is invalid run data' do
        let(:body) do
          {
            data: {
              type: 'runs',
              attributes: {
                system_name: 'invalid'
              }
            }
          }.to_json
        end

        it 'has a bad_request status' do
          post v1_pacbio_runs_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:bad_request)
        end

        it 'does not create a run' do
          expect do
            post v1_pacbio_runs_path, params: body,
                                      headers: json_api_headers
          end.not_to change(Pacbio::Run, :count)
        end

        it 'has the correct error messages' do
          post v1_pacbio_runs_path, params: body, headers: json_api_headers
          json = ActiveSupport::JSON.decode(response.body)
          errors = json['errors']
          expect(errors[0]['detail']).to eq 'invalid is not a valid value for system_name.'
        end
      end

      context 'when there no wells' do
        let(:pool1) { create(:pacbio_pool) }

        let(:body) do
          {
            data: {
              type: 'runs',
              attributes: {
                sequencing_kit_box_barcode: 'DM0001100861800123121',
                dna_control_complex_box_barcode: 'Lxxxxx101717600123191',
                system_name: 'Sequel II',
                comments: 'A Run Comment',
                pacbio_smrt_link_version_id: version11.id,
                well_attributes: []
              }
            }
          }.to_json
        end

        it 'has a unprocessable_entity status' do
          post v1_pacbio_runs_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not create a run' do
          expect do
            post v1_pacbio_runs_path, params: body,
                                      headers: json_api_headers
          end.not_to change(Pacbio::Run, :count)
        end

        it 'does not create a well' do
          expect do
            post v1_pacbio_runs_path, params: body,
                                      headers: json_api_headers
          end.not_to change(Pacbio::Well, :count)
        end

        it 'has the correct error messages' do
          post v1_pacbio_runs_path, params: body, headers: json_api_headers
          json = ActiveSupport::JSON.decode(response.body)
          errors = json['errors']
          expect(errors[0]['detail']).to eq 'plate.wells - there must be at least one well'
        end
      end

      context 'when there is missing well data' do
        let(:pool1) { create(:pacbio_pool) }

        let(:body) do
          {
            data: {
              type: 'runs',
              attributes: {
                sequencing_kit_box_barcode: 'DM0001100861800123121',
                dna_control_complex_box_barcode: 'Lxxxxx101717600123191',
                system_name: 'Sequel II',
                comments: 'A Run Comment',
                pacbio_smrt_link_version_id: version11.id,
                well_attributes: [{
                  row: 'A',
                  pools: [pool1.id]
                }]
              }
            }
          }.to_json
        end

        it 'has a unprocessable_entity status' do
          post v1_pacbio_runs_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not create a run' do
          expect do
            post v1_pacbio_runs_path, params: body,
                                      headers: json_api_headers
          end.not_to change(Pacbio::Run, :count)
        end

        it 'does not create a a well' do
          expect do
            post v1_pacbio_runs_path, params: body,
                                      headers: json_api_headers
          end.not_to change(Pacbio::Well, :count)
        end

        it 'has the correct error messages' do
          post v1_pacbio_runs_path, params: body, headers: json_api_headers
          json = ActiveSupport::JSON.decode(response.body)
          errors = json['errors']
          expect(errors[0]['detail']).to eq "plate.wells.column - can't be blank"
        end
      end

      context 'when there are no well pools' do
        let(:body) do
          {
            data: {
              type: 'runs',
              attributes: {
                sequencing_kit_box_barcode: 'DM0001100861800123121',
                dna_control_complex_box_barcode: 'Lxxxxx101717600123191',
                system_name: 'Sequel II',
                comments: 'A Run Comment',
                pacbio_smrt_link_version_id: version11.id,
                well_attributes: [
                  { row: 'A',
                    column: '1',
                    movie_time: 8,
                    on_plate_loading_concentration: 8.35,
                    pre_extension_time: '2',
                    generate_hifi: 'In SMRT Link',
                    ccs_analysis_output: 'Yes',
                    binding_kit_box_barcode: 'DM1117100862200111711',
                    ccs_analysis_output_include_low_quality_reads: 'Yes',
                    include_fivemc_calls_in_cpg_motifs: 'Yes',
                    ccs_analysis_output_include_kinetics_information: 'Yes',
                    demultiplex_barcodes: 'In SMRT Link',
                    pools: [] }
                ]
              }
            }
          }.to_json
        end

        it 'has a unprocessable_entity status' do
          post v1_pacbio_runs_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not create a run' do
          expect do
            post v1_pacbio_runs_path, params: body,
                                      headers: json_api_headers
          end.not_to change(Pacbio::Run, :count)
        end

        it 'does not create a a well' do
          expect do
            post v1_pacbio_runs_path, params: body,
                                      headers: json_api_headers
          end.not_to change(Pacbio::Well, :count)
        end

        it 'has the correct error messages' do
          post v1_pacbio_runs_path, params: body, headers: json_api_headers
          json = ActiveSupport::JSON.decode(response.body)
          errors = json['errors']
          expect(errors[0]['detail']).to eq 'plate.wells.pools - there must be at least one pool'
        end
      end

      context 'when the well pool does not exist' do
        let(:body) do
          {
            data: {
              type: 'runs',
              attributes: {
                sequencing_kit_box_barcode: 'DM0001100861800123121',
                dna_control_complex_box_barcode: 'Lxxxxx101717600123191',
                system_name: 'Sequel II',
                comments: 'A Run Comment',
                pacbio_smrt_link_version_id: version11.id,
                well_attributes: [
                  { row: 'A',
                    column: '1',
                    movie_time: 8,
                    on_plate_loading_concentration: 8.35,
                    pre_extension_time: '2',
                    generate_hifi: 'In SMRT Link',
                    ccs_analysis_output: 'Yes',
                    binding_kit_box_barcode: 'DM1117100862200111711',
                    ccs_analysis_output_include_low_quality_reads: 'Yes',
                    include_fivemc_calls_in_cpg_motifs: 'Yes',
                    ccs_analysis_output_include_kinetics_information: 'Yes',
                    demultiplex_barcodes: 'In SMRT Link',
                    pools: [123] }
                ]
              }
            }
          }.to_json
        end

        it 'has a internal_server_error status' do
          post v1_pacbio_runs_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:internal_server_error)
        end

        it 'does not create a run' do
          expect do
            post v1_pacbio_runs_path, params: body,
                                      headers: json_api_headers
          end.not_to change(Pacbio::Run, :count)
        end

        it 'does not create a a well' do
          expect do
            post v1_pacbio_runs_path, params: body,
                                      headers: json_api_headers
          end.not_to change(Pacbio::Well, :count)
        end

        it 'has the correct error messages' do
          post v1_pacbio_runs_path, params: body, headers: json_api_headers
          json = ActiveSupport::JSON.decode(response.body)
          errors = json['errors']
          expect(errors[0]['detail']).to eq 'Internal Server Error'
        end
      end

      context 'when there is one well with two duplicate (library tags) pools' do
        let!(:pool1) { create(:pacbio_pool, :tagged) }

        let(:body) do
          {
            data: {
              type: 'runs',
              attributes: {
                sequencing_kit_box_barcode: 'DM0001100861800123121',
                dna_control_complex_box_barcode: 'Lxxxxx101717600123191',
                system_name: 'Sequel II',
                comments: 'A Run Comment',
                pacbio_smrt_link_version_id: version11.id,
                well_attributes: [
                  { row: 'A',
                    column: '1',
                    movie_time: 8,
                    on_plate_loading_concentration: 8.35,
                    pre_extension_time: '2',
                    generate_hifi: 'In SMRT Link',
                    ccs_analysis_output: 'Yes',
                    binding_kit_box_barcode: 'DM1117100862200111711',
                    ccs_analysis_output_include_low_quality_reads: 'Yes',
                    include_fivemc_calls_in_cpg_motifs: 'Yes',
                    ccs_analysis_output_include_kinetics_information: 'Yes',
                    demultiplex_barcodes: 'In SMRT Link',
                    pools: [pool1.id, pool1.id] }
                ]
              }
            }
          }.to_json
        end

        it 'has a unprocessable_entity status' do
          post v1_pacbio_runs_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not create a run' do
          expect do
            post v1_pacbio_runs_path, params: body,
                                      headers: json_api_headers
          end.not_to change(Pacbio::Run, :count)
        end

        it 'does not create a a well' do
          expect do
            post v1_pacbio_runs_path, params: body,
                                      headers: json_api_headers
          end.not_to change(Pacbio::Well, :count)
        end

        it 'has the correct error messages' do
          post v1_pacbio_runs_path, params: body, headers: json_api_headers
          json = ActiveSupport::JSON.decode(response.body)
          errors = json['errors']
          expect(errors[0]['detail']).to eq 'plate.wells.tags - are not unique within the libraries for well A1'
        end
      end

      context 'when there are two wells with the same pool' do
        let!(:pool1) { create(:pacbio_pool, :tagged) }

        let(:body) do
          {
            data: {
              type: 'runs',
              attributes: {
                sequencing_kit_box_barcode: 'DM0001100861800123121',
                dna_control_complex_box_barcode: 'Lxxxxx101717600123191',
                system_name: 'Sequel II',
                comments: 'A Run Comment',
                pacbio_smrt_link_version_id: version11.id,
                well_attributes: [
                  { row: 'A',
                    column: '1',
                    movie_time: 8,
                    on_plate_loading_concentration: 8.35,
                    pre_extension_time: '2',
                    generate_hifi: 'In SMRT Link',
                    ccs_analysis_output: 'Yes',
                    binding_kit_box_barcode: 'DM1117100862200111711',
                    ccs_analysis_output_include_low_quality_reads: 'Yes',
                    include_fivemc_calls_in_cpg_motifs: 'Yes',
                    ccs_analysis_output_include_kinetics_information: 'Yes',
                    demultiplex_barcodes: 'In SMRT Link',
                    pools: [pool1.id] },
                  { row: 'A',
                    column: '2',
                    movie_time: 8,
                    on_plate_loading_concentration: 8.35,
                    pre_extension_time: '2',
                    generate_hifi: 'In SMRT Link',
                    ccs_analysis_output: 'Yes',
                    binding_kit_box_barcode: 'DM1117100862200111711',
                    ccs_analysis_output_include_low_quality_reads: 'Yes',
                    include_fivemc_calls_in_cpg_motifs: 'Yes',
                    ccs_analysis_output_include_kinetics_information: 'Yes',
                    demultiplex_barcodes: 'In SMRT Link',
                    pools: [pool1.id] }
                ]
              }
            }
          }.to_json
        end

        it 'has a created status' do
          post v1_pacbio_runs_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:created)
        end

        it 'creates a run' do
          expect { post v1_pacbio_runs_path, params: body, headers: json_api_headers }.to change(Pacbio::Run, :count).by(1)
        end

        it 'creates a plate' do
          expect { post v1_pacbio_runs_path, params: body, headers: json_api_headers }.to change(Pacbio::Plate, :count).by(1)
        end

        it 'creates a well' do
          expect { post v1_pacbio_runs_path, params: body, headers: json_api_headers }.to change(Pacbio::Well, :count).by(2)
        end

        it 'creates a well pool' do
          expect { post v1_pacbio_runs_path, params: body, headers: json_api_headers }.to change(Pacbio::WellPool, :count).by(2)
        end

        it 'creates a run with the correct attributes' do
          post v1_pacbio_runs_path, params: body, headers: json_api_headers
          json = ActiveSupport::JSON.decode(response.body)
          run = Pacbio::Run.first

          expect(run.id).to eq(json['data']['id'].to_i)
          expect(run.name).to be_present
        end
      end

      context 'when there is one well with two pools, without tags' do
        let(:pool1) { create(:pacbio_pool, libraries: create_list(:pacbio_library_without_tag, 1)) }
        let(:pool2) { create(:pacbio_pool, libraries: create_list(:pacbio_library_without_tag, 1)) }

        let(:body) do
          {
            data: {
              type: 'runs',
              attributes: {
                sequencing_kit_box_barcode: 'DM0001100861800123121',
                dna_control_complex_box_barcode: 'Lxxxxx101717600123191',
                system_name: 'Sequel II',
                comments: 'A Run Comment',
                pacbio_smrt_link_version_id: version11.id,
                well_attributes: [
                  { row: 'A',
                    column: '1',
                    movie_time: 8,
                    on_plate_loading_concentration: 8.35,
                    pre_extension_time: '2',
                    generate_hifi: 'In SMRT Link',
                    ccs_analysis_output: 'Yes',
                    binding_kit_box_barcode: 'DM1117100862200111711',
                    ccs_analysis_output_include_low_quality_reads: 'Yes',
                    include_fivemc_calls_in_cpg_motifs: 'Yes',
                    ccs_analysis_output_include_kinetics_information: 'Yes',
                    demultiplex_barcodes: 'In SMRT Link',
                    pools: [pool1.id, pool2.id] }
                ]
              }
            }
          }.to_json
        end

        it 'has a unprocessable_entity status' do
          post v1_pacbio_runs_path, params: body, headers: json_api_headers
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not create a run' do
          expect do
            post v1_pacbio_runs_path, params: body,
                                      headers: json_api_headers
          end.not_to change(Pacbio::Run, :count)
        end

        it 'does not create a a well' do
          expect do
            post v1_pacbio_runs_path, params: body,
                                      headers: json_api_headers
          end.not_to change(Pacbio::Well, :count)
        end

        it 'has the correct error messages' do
          post v1_pacbio_runs_path, params: body, headers: json_api_headers
          json = ActiveSupport::JSON.decode(response.body)
          errors = json['errors']
          expect(errors[0]['detail']).to eq 'plate.wells.tags - are missing from the libraries'
        end
      end
    end
  end

  describe '#create run with default smrt link version implicitly' do
    # Set no smrt link version id in request body.
    let(:pool1) { create(:pacbio_pool) }

    let(:body) do
      {
        data: {
          type: 'runs',
          attributes: {
            sequencing_kit_box_barcode: 'DM0001100861800123121',
            dna_control_complex_box_barcode: 'Lxxxxx101717600123191',
            system_name: 'Sequel II',
            comments: 'A Run Comment',
            well_attributes: [
              {
                row: 'A',
                column: '1',
                movie_time: 8,
                on_plate_loading_concentration: 8.35,
                pre_extension_time: '2',
                generate_hifi: 'In SMRT Link',
                ccs_analysis_output: 'Yes',
                binding_kit_box_barcode: 'DM1117100862200111711',
                ccs_analysis_output_include_low_quality_reads: 'Yes',
                include_fivemc_calls_in_cpg_motifs: 'Yes',
                ccs_analysis_output_include_kinetics_information: 'Yes',
                demultiplex_barcodes: 'In SMRT Link',
                pools: [pool1.id]
              }
            ]
          }
        }
      }.to_json
    end

    context 'on success' do
      it 'creates a run with the correct attributes' do
        post v1_pacbio_runs_path, params: body, headers: json_api_headers
        json = ActiveSupport::JSON.decode(response.body)
        run = Pacbio::Run.first
        version = Pacbio::SmrtLinkVersion.find_by(default: true)
        expect(run.id).to eq(json['data']['id'].to_i)
        expect(version).to eq(version10)
        expect(run.smrt_link_version).to be_present
        expect(run.smrt_link_version).to eq(version)
        expect(run.pacbio_smrt_link_version_id).to eq(version.id)
      end

      it_behaves_like 'publish_messages_on_create'
    end
  end

  describe '#create run with default smrt link version explicitly' do
    # Set default smrt link version id in request body.
    let(:pool1) { create(:pacbio_pool) }

    let(:body) do
      {
        data: {
          type: 'runs',
          attributes: {
            sequencing_kit_box_barcode: 'DM0001100861800123121',
            dna_control_complex_box_barcode: 'Lxxxxx101717600123191',
            system_name: 'Sequel II',
            comments: 'A Run Comment',
            pacbio_smrt_link_version_id: version10.id,
            well_attributes: [
              { row: 'A',
                column: '1',
                movie_time: 8,
                on_plate_loading_concentration: 8.35,
                pre_extension_time: '2',
                generate_hifi: 'In SMRT Link',
                ccs_analysis_output: 'Yes',
                binding_kit_box_barcode: 'DM1117100862200111711',
                ccs_analysis_output_include_low_quality_reads: 'Yes',
                include_fivemc_calls_in_cpg_motifs: 'Yes',
                ccs_analysis_output_include_kinetics_information: 'Yes',
                demultiplex_barcodes: 'In SMRT Link',
                pools: [pool1.id] }
            ]
          }
        }
      }.to_json
    end

    context 'on success' do
      it 'creates a run with the correct attributes' do
        post v1_pacbio_runs_path, params: body, headers: json_api_headers
        json = ActiveSupport::JSON.decode(response.body)
        run = Pacbio::Run.first
        version = Pacbio::SmrtLinkVersion.find_by(default: true)

        expect(run.id).to eq(json['data']['id'].to_i)
        expect(version).to eq(version10)
        expect(run.smrt_link_version).to be_present
        expect(run.smrt_link_version).to eq(version)
        expect(run.pacbio_smrt_link_version_id).to eq(version.id)
      end

      it_behaves_like 'publish_messages_on_create'
    end
  end

  describe '#update' do
    context 'on success' do
      context 'when run state is successful' do
        let!(:run) { create(:pacbio_run) }
        let!(:plate) { create(:pacbio_plate, run:) }
        let(:body) do
          {
            data: {
              type: 'runs',
              id: run.id,
              attributes: {
                state: 'started'
              }
            }
          }.to_json
        end

        it 'has a ok status' do
          patch v1_pacbio_run_path(run), params: body, headers: json_api_headers
          expect(response).to have_http_status(:ok)
        end

        it 'updates a run' do
          patch v1_pacbio_run_path(run), params: body, headers: json_api_headers
          run.reload
          expect(run.state).to eq 'started'
        end

        it 'returns the correct attributes' do
          patch v1_pacbio_run_path(run), params: body, headers: json_api_headers
          json = ActiveSupport::JSON.decode(response.body)
          expect(json['data']['id']).to eq run.id.to_s
        end

        it 'retains the existing plate, wells, pools etc' do
          existing_wells = run.plate.wells
          existing_pools = run.plate.wells.map(&:pools)
          patch v1_pacbio_run_path(run), params: body, headers: json_api_headers
          run.reload
          expect(run.plate).to eq plate
          expect(run.plate.wells).to eq existing_wells
          expect(run.plate.wells.map(&:pools)).to eq existing_pools
        end

        it_behaves_like 'publish_messages_on_update'
      end

      context 'when run info is successful' do
        let(:body) do
          {
            data: {
              id: run.id,
              type: 'runs',
              attributes: {
                sequencing_kit_box_barcode: 'DM0001100861800123121_updated',
                dna_control_complex_box_barcode: 'Lxxxxx101717600123191_updated',
                system_name: 'Sequel I',
                comments: 'A Run Comment updated'
              }
            }
          }.to_json
        end
        let!(:run) { create(:pacbio_run) }
        let!(:plate) { create(:pacbio_plate, run:) }

        it 'has a ok status' do
          patch v1_pacbio_run_path(run), params: body, headers: json_api_headers
          expect(response).to have_http_status(:ok)
        end

        it 'does not create a run' do
          expect do
            patch v1_pacbio_run_path(run), params: body, headers: json_api_headers
          end.not_to change(Pacbio::Run, :count)
        end

        it 'updates a run' do
          patch v1_pacbio_run_path(run), params: body, headers: json_api_headers
          run.reload
          expect(run.sequencing_kit_box_barcode).to eq 'DM0001100861800123121_updated'
          expect(run.dna_control_complex_box_barcode).to eq 'Lxxxxx101717600123191_updated'
          expect(run.system_name).to eq 'Sequel I'
          expect(run.comments).to eq 'A Run Comment updated'
          expect(run.state).to eq 'pending'
        end

        it_behaves_like 'publish_messages_on_update'
      end

      context 'when well info is successful' do
        let!(:run) { create(:pacbio_run) }
        let!(:plate) { create(:pacbio_plate, run:) }
        let!(:well) { plate.wells.first }
        let!(:pool1) { create(:pacbio_pool) }

        let(:body) do
          {
            data: {
              id: run.id,
              type: 'runs',
              attributes: {
                well_attributes: [
                  {
                    id: well.id.to_s, # We receive ids in string format from the ui
                    row: 'D',
                    column: '7',
                    movie_time: 7,
                    on_plate_loading_concentration: 7.35,
                    binding_kit_box_barcode: 'DM1117100862200111711_updated',
                    pools: [pool1.id]
                  }
                ]
              }
            }
          }.to_json
        end

        it 'has a ok status' do
          patch v1_pacbio_run_path(run), params: body, headers: json_api_headers
          expect(response).to have_http_status(:ok)
        end

        it 'does not create a well' do
          expect do
            patch v1_pacbio_run_path(run), params: body, headers: json_api_headers
          end.not_to change(Pacbio::Well, :count)
        end

        it 'updates a well' do
          patch v1_pacbio_run_path(run), params: body, headers: json_api_headers
          well.reload
          expect(well.row).to eq 'D'
          expect(well.column).to eq '7'
          expect(well.movie_time).to eq 7
          expect(well.on_plate_loading_concentration).to eq 7.35
          expect(well.binding_kit_box_barcode).to eq 'DM1117100862200111711_updated'
        end

        it_behaves_like 'publish_messages_on_update'
      end

      context 'when well is added, removed and updated' do
        let!(:run) { create(:pacbio_run) }
        let!(:plate) { create(:pacbio_plate, run:, well_count: 2) }
        let!(:well1) { plate.wells[0] }
        let!(:well2) { plate.wells[1] }
        let(:pool1) { create(:pacbio_pool) }

        let(:body) do
          {
            data: {
              id: run.id,
              type: 'runs',
              attributes: {
                well_attributes: [
                  {
                    row: 'F',
                    column: '12',
                    movie_time: 8,
                    on_plate_loading_concentration: 8.35,
                    pre_extension_time: '2',
                    generate_hifi: 'In SMRT Link',
                    ccs_analysis_output: 'Yes',
                    binding_kit_box_barcode: 'DM1117100862200111711',
                    ccs_analysis_output_include_low_quality_reads: 'Yes',
                    include_fivemc_calls_in_cpg_motifs: 'Yes',
                    ccs_analysis_output_include_kinetics_information: 'Yes',
                    demultiplex_barcodes: 'In SMRT Link',
                    pools: [pool1.id]
                  },
                  {
                    id: well1.id.to_s,
                    row: 'D',
                    column: '7',
                    pools: [well1.pools[0].id]
                  }
                ]
              }
            }
          }.to_json
        end

        it 'has a ok status' do
          patch v1_pacbio_run_path(run), params: body, headers: json_api_headers
          expect(response).to have_http_status(:ok)
        end

        # Creates a well and deletes a well = +1-1 = 0
        it 'does not create a well' do
          expect do
            patch v1_pacbio_run_path(run), params: body, headers: json_api_headers
          end.not_to change(Pacbio::Well, :count)
        end

        # Each well previously had 5 pools each
        # Now each well has 1 pool
        # Therefore, WellPool count changed from 10 to 2
        it 'does not create a well pool' do
          expect do
            patch v1_pacbio_run_path(run), params: body, headers: json_api_headers
          end.to change(Pacbio::WellPool, :count).from(10).to(2)
        end

        it 'updates a well' do
          patch v1_pacbio_run_path(run), params: body, headers: json_api_headers
          run.reload
          expect(run.wells.length).to eq 2
          expect(run.wells[0].row).to eq 'D'
          expect(run.wells[0].column).to eq '7'
          expect(run.wells[1].row).to eq 'F'
          expect(run.wells[1].column).to eq '12'
        end

        it_behaves_like 'publish_messages_on_update'
      end

      context 'when pool is added, removed and updated' do
        let!(:run) { create(:pacbio_run) }
        let!(:plate) { create(:pacbio_plate, run:, well_count: 2) }
        let!(:well1) { plate.wells[0] }
        let!(:well2) { plate.wells[1] }
        let!(:pool1) { create(:pacbio_pool) }
        let!(:pool2) { create(:pacbio_pool) }
        let!(:pool3) { create(:pacbio_pool) }

        let(:body) do
          {
            data: {
              id: run.id,
              type: 'runs',
              attributes: {
                well_attributes: [
                  {
                    id: run.wells[0].id.to_s,
                    pools: [well1.pools[0].id, pool1.id]
                  },
                  {
                    id: run.wells[1].id.to_s,
                    pools: [pool2.id]
                  }
                ]
              }
            }
          }.to_json
        end

        it 'has a ok status' do
          patch v1_pacbio_run_path(run), params: body, headers: json_api_headers
          expect(response).to have_http_status(:ok)
        end

        # Creates a well and deletes a well = +1-1 = 0
        it 'does not create a well' do
          expect do
            patch v1_pacbio_run_path(run), params: body, headers: json_api_headers
          end.not_to change(Pacbio::Well, :count)
        end

        # Each well previously had 5 pools each
        # Now there are 3 pools
        # Therefore, WellPool count changed from 10 to 3
        it 'does creates a well pool' do
          expect do
            patch v1_pacbio_run_path(run), params: body, headers: json_api_headers
          end.to change(Pacbio::WellPool, :count).from(10).to(3)
        end

        it 'updates a well' do
          patch v1_pacbio_run_path(run), params: body, headers: json_api_headers
          run.reload
          expect(run.wells.length).to eq 2
          expect(run.wells[0].pools.length).to eq 2
          expect(run.wells[0].pools).to include well1.pools[0]
          expect(run.wells[0].pools).to include pool1
          expect(run.wells[1].pools.length).to eq 1
          expect(run.wells[1].pools).to include pool2
        end

        it_behaves_like 'publish_messages_on_update'
      end
    end

    context 'on failure' do
      let!(:run) { create(:pacbio_run) }
      let!(:plate) { create(:pacbio_plate, run:, well_count: 2) }

      let(:body) do
        {
          data: {
            type: 'runs',
            id: run.id,
            attributes: {
              state: 'unknown'
            }
          }
        }.to_json
      end

      it 'has a bad_request' do
        patch v1_pacbio_run_path(run.id), params: body, headers: json_api_headers
        expect(response).to have_http_status(:bad_request)
      end

      it 'has an error message' do
        patch v1_pacbio_run_path(run.id), params: body, headers: json_api_headers
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['errors'][0]['detail']).to eq 'unknown is not a valid value for state.'
      end

      it 'does not update a run' do
        patch v1_pacbio_run_path(run.id), params: body, headers: json_api_headers
        run.reload
        expect(run).to be_pending
      end
    end
  end

  describe '#show' do
    let!(:run) { create(:pacbio_run) }
    let!(:plate) { create(:pacbio_plate, run:) }

    it 'returns the runs' do
      get v1_pacbio_run_path(run), headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data']['id']).to eq(run.id.to_s)
    end

    it 'returns the correct attributes' do
      get v1_pacbio_run_path(run), headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data']['id']).to eq(run.id.to_s)
      expect(json['data']['attributes']['state']).to eq(run.state)
      expect(json['data']['attributes']['name']).to eq(run.name)
      expect(json['data']['attributes']['sequencing_kit_box_barcode']).to eq(run.sequencing_kit_box_barcode)
      expect(json['data']['attributes']['dna_control_complex_box_barcode']).to eq(run.dna_control_complex_box_barcode)
      expect(json['data']['attributes']['system_name']).to eq(run.system_name)
    end

    it 'returns the correct relationships' do
      get "#{v1_pacbio_run_path(run)}?include=plate", headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data']['relationships']['plate']).to be_present
      expect(json['data']['relationships']['plate']['data']['type']).to eq 'plates'
      expect(json['data']['relationships']['plate']['data']['id']).to eq plate.id.to_s
    end

    it 'returns the correct includes' do
      get "#{v1_pacbio_run_path(run)}?include=plate", headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['included'][0]['id']).to eq plate.id.to_s
      expect(json['included'][0]['type']).to eq 'plates'
    end
  end

  describe '#destroy' do
    let!(:run) { create(:pacbio_run) }
    let!(:plate1) { create(:pacbio_plate, run:) }

    context 'on success' do
      it 'returns the correct status' do
        delete v1_pacbio_run_path(run), headers: json_api_headers
        expect(response).to have_http_status(:no_content)
      end

      it 'deletes the run' do
        expect { delete v1_pacbio_run_path(run), headers: json_api_headers }.to change(Pacbio::Run, :count).by(-1)
      end

      it 'deletes the plate' do
        expect { delete v1_pacbio_run_path(run), headers: json_api_headers }.to change(Pacbio::Plate, :count).by(-1)
      end
    end

    context 'on failure' do
      it 'does not delete the run' do
        delete '/v1/pacbio/runs/123', headers: json_api_headers
        expect(response).to have_http_status(:not_found)
      end

      it 'has an error message' do
        delete '/v1/pacbio/runs/123', headers: json_api_headers
        body = response.parsed_body
        expect(body['errors']).to be_present
      end
    end
  end

  describe '#sample_sheet' do
    let(:well1)   { create(:pacbio_well_with_pools) }
    let(:well2)   { create(:pacbio_well_with_pools) }
    let(:plate)   { create(:pacbio_plate, wells: [well1, well2]) }
    let(:run)     { create(:pacbio_run, smrt_link_version: version10, plate:) }

    after { FileUtils.rm_rf("#{run.name}.csv") }

    it 'returns the correct status' do
      get v1_pacbio_run_sample_sheet_path(run).to_s, headers: json_api_headers
      expect(response).to have_http_status(:success)
    end

    it 'returns a CSV file' do
      get v1_pacbio_run_sample_sheet_path(run).to_s, headers: json_api_headers
      expect(response.header['Content-Type']).to include 'text/csv'
    end

    it 'the attached csv file is named after the run its assoicated with' do
      get v1_pacbio_run_sample_sheet_path(run).to_s, headers: json_api_headers
      expect(response.header['Content-Disposition']).to include "#{run.name}.csv"
    end
  end
end

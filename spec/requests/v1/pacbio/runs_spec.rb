# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'RunsController' do
  # Create default and non-default smrt link versions for runs
  let!(:version10) { create(:pacbio_smrt_link_version, name: 'v10', default: true) }
  let!(:version11) { create(:pacbio_smrt_link_version, name: 'v11') }

  describe '#get' do
    let!(:run1) { create(:pacbio_run, state: 'pending') }
    let!(:run2) { create(:pacbio_run, state: 'started') }
    let!(:plate1) { create(:pacbio_plate, run: run1) }
    let!(:plate2) { create(:pacbio_plate, run: run2) }

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
      expect(json['data'][0]['attributes']['all_wells_have_pools']).to eq(run1.all_wells_have_pools?)
      expect(json['data'][1]['attributes']['name']).to eq(run2.name)
    end

    it 'returns the correct relationships', aggregate_failures: true do
      get "#{v1_pacbio_runs_path}?include=plate,smrt_link_version", headers: json_api_headers

      expect(response).to have_http_status(:success), response.body
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data'][0]['relationships']['plate']).to be_present
      expect(json['data'][0]['relationships']['plate']['data']['type']).to eq 'plates'
      expect(json['data'][0]['relationships']['plate']['data']['id']).to eq plate1.id.to_s

      expect(json['data'][1]['relationships']['plate']).to be_present
      expect(json['data'][1]['relationships']['plate']['data']['type']).to eq 'plates'
      expect(json['data'][1]['relationships']['plate']['data']['id']).to eq plate2.id.to_s

      expect(json['data'][0]['relationships']['smrt_link_version']).to be_present
      expect(json['data'][0]['relationships']['smrt_link_version']['data']['type']).to eq 'smrt_link_versions'
      expect(json['data'][0]['relationships']['smrt_link_version']['data']['id']).to eq run1.smrt_link_version.id.to_s
    end

    context 'pagination' do
      let!(:expected_runs) { create_list(:pacbio_run, 2, created_at: Time.zone.now + 10) }

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

  # Add to pools list
  # {
  #   type: 'libraries',
  #   id: pool2.id
  # }
  describe '#create' do
    # Set a non-default smrt link version id in request body.
    let(:pool1) { create(:pacbio_pool) }

    let(:body) do
      {
        data: {
          type: 'runs',
          # attributes: attributes_for(:pacbio_run, pacbio_smrt_link_version_id: version11.id),
          attributes: {
            sequencing_kit_box_barcode: 'DM0001100861800123121',
            dna_control_complex_box_barcode: 'Lxxxxx101717600123191',
            system_name: 'Sequel II',
            comments: 'A Run Comment',
            pacbio_smrt_link_version_id: version11.id,
            wells_attributes: [
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
                pools: [
                  {
                    id: pool1.id
                  }
                ] }
            ]
          }
        }
      }.to_json
    end

    context 'on success' do
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
    end

    context 'on failure' do
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
            wells_attributes: [
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
                pools: [
                  {
                    id: pool1.id
                  }
                ] }
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
    end
  end

  # TODO
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
            wells_attributes: [
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
                pools: [
                  {
                    id: pool1.id
                  }
                ] }
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
    end
  end

  describe '#update' do
    before do
      @run = create(:pacbio_run)
      @plate = create(:pacbio_plate, run: @run)
    end

    context 'on success' do
      let(:body) do
        {
          data: {
            type: 'runs',
            id: @run.id,
            attributes: {
              state: 'started'
            }
          }
        }.to_json
      end

      it 'has a ok status' do
        patch v1_pacbio_run_path(@run), params: body, headers: json_api_headers
        expect(response).to have_http_status(:ok)
      end

      it 'updates a run' do
        patch v1_pacbio_run_path(@run), params: body, headers: json_api_headers
        @run.reload
        expect(@run.state).to eq 'started'
      end

      it 'returns the correct attributes' do
        patch v1_pacbio_run_path(@run), params: body, headers: json_api_headers
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['data']['id']).to eq @run.id.to_s
      end
    end

    context 'on failure' do
      let(:body) do
        {
          data: {
            type: 'runs',
            id: 123,
            attributes: {
              state: 'started'
            }
          }
        }.to_json
      end

      it 'has a ok unprocessable_entity' do
        patch v1_pacbio_run_path(123), params: body, headers: json_api_headers
        expect(response).to have_http_status(:not_found)
      end

      it 'has an error message' do
        patch v1_pacbio_run_path(123), params: body, headers: json_api_headers
        json = JSON.parse(response.body)
        expect(json['errors'][0]['detail']).to eq 'The record identified by 123 could not be found.'
      end

      it 'does not update a run' do
        patch v1_saphyr_run_path(123), params: body, headers: json_api_headers
        @run.reload
        expect(@run).to be_pending
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
        body = JSON.parse(response.body)
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

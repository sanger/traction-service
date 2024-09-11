# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'WorkflowsController', type: :request do
  describe '#get' do
    let!(:workflow1) { create(:workflow, pipeline: 0) }
    let!(:workflow2) { create(:workflow, pipeline: 1) }
    let!(:workflow_step1) { create(:workflow_step, workflow: workflow1, code: 'Code_Stage1', stage: 'Stage 1') }
    let!(:workflow_step2) { create(:workflow_step, workflow: workflow2, code: 'Code_Stage2', stage: 'Stage 2') }

    it 'returns a list of active workflows' do
      get v1_workflows_path, headers: json_api_headers
      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)
      expect(json['data'].length).to eq(2)
    end

    it 'returns the correct attributes' do
      get v1_workflows_path, headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      expect(json['data'][0]['attributes']['name']).to eq(workflow1.name)
      expect(json['data'][1]['attributes']['name']).to eq(workflow2.name)
      expect(json['data'][0]['attributes']['pipeline']).to eq('pacbio')
      expect(json['data'][1]['attributes']['pipeline']).to eq('ont')
    end

    it 'includes workflow steps data' do
      get "#{v1_workflows_path}?include=workflow_steps", headers: json_api_headers

      expect(response).to have_http_status(:success)
      json = ActiveSupport::JSON.decode(response.body)

      workflow1_data = json['data'].find { |w| w['id'] == workflow1.id.to_s }
      workflow2_data = json['data'].find { |w| w['id'] == workflow2.id.to_s }
      expect(workflow1_data['relationships']['workflow_steps']['data'].length).to eq(1)
      expect(workflow2_data['relationships']['workflow_steps']['data'].length).to eq(1)

      workflow_step1_data = workflow1_data['relationships']['workflow_steps']['data'].first
      workflow_step2_data = workflow2_data['relationships']['workflow_steps']['data'].first

      workflow_step1_include = json['included'].find { |i| i['id'] == workflow_step1_data['id'].to_s }
      workflow_step2_include = json['included'].find { |i| i['id'] == workflow_step2_data['id'].to_s }

      expect(workflow_step1_include['attributes']['code']).to eq(workflow_step1.code)
      expect(workflow_step2_include['attributes']['code']).to eq(workflow_step2.code)
      expect(workflow_step1_include['attributes']['stage']).to eq(workflow_step1.stage)
      expect(workflow_step2_include['attributes']['stage']).to eq(workflow_step2.stage)
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SmrtLinkVersionsController' do
  def json
    ActiveSupport::JSON.decode(response.body)
  end

  describe '#get' do
    let!(:default_smrt_link_version) { create(:pacbio_smrt_link_version, default: true) }

    before do
      create_list(:pacbio_smrt_link_version, 5)
      create_list(:pacbio_smrt_link_version, 2, active: false)

      get v1_pacbio_smrt_link_versions_path, headers: json_api_headers
    end

    it 'returns a response' do
      expect(response).to have_http_status(:success)
    end

    it 'includes active and inactive versions' do
      expect(json['data'].length).to eq(8)
    end

    it 'will include the correct data' do
      expect(json['data'][0]['attributes']['name']).to eq(default_smrt_link_version.name)
      expect(json['data'][0]['attributes']['default']).to be_truthy
      expect(json['data'][0]['attributes']['active']).to be true
      expect(json['data'][7]['attributes']['active']).to be false
    end
  end

  describe '#options' do
    let!(:smrt_link_version_1)          { create(:pacbio_smrt_link_version_with_options, option_count: 2) }
    let!(:smrt_link_version_2)          { create(:pacbio_smrt_link_version_with_options, option_count: 3) }

    before do
      get "#{v1_pacbio_smrt_link_versions_path}?include=smrt_link_option_versions.smrt_link_option", headers: json_api_headers
    end

    it 'returns a response' do
      expect(response).to have_http_status(:success)
    end

    it 'will include all of the options' do
      expect(json['data'][0]['relationships']['smrt_link_option_versions']['data'].length).to eq(smrt_link_version_1.smrt_link_options.length)
      expect(json['data'][1]['relationships']['smrt_link_option_versions']['data'].length).to eq(smrt_link_version_2.smrt_link_options.length)
    end

    it 'will include the data for each option' do
      option = smrt_link_version_1.smrt_link_options.first
      option_json = json['included'].detect { |opt| opt['id'] == option.id.to_s && opt['type'] == 'smrt_link_options' }
      expect(option_json['attributes']).to be_present
      expect(option_json['attributes']['key']).to eq(option.key)
      expect(option_json['attributes']['label']).to eq(option.label)
      expect(option_json['attributes']['default_value']).to eq(option.default_value)
      expect(option_json['attributes']['data_type']).to eq(option.data_type)
      expect(option_json['attributes']['select_option']).to eq(option.select_options)
    end
  end
end

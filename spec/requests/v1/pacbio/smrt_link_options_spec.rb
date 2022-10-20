# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SmrtLinkOptionsController', type: :request do
  def json
    ActiveSupport::JSON.decode(response.body)
  end

  describe '#get' do
    let!(:smrt_link_options) { create_list(:pacbio_smrt_link_option, 5, select_options: 'a,b,c') }

    before do
      get v1_pacbio_smrt_link_options_path, headers: json_api_headers
    end

    it 'returns a response' do
      expect(response).to have_http_status(:success)
    end

    it 'includes the correct number of options' do
      expect(json['data'].length).to eq(5)
    end

    it 'will include the correct data' do
      resource = json['data'][0]['attributes']
      option = smrt_link_options.first
      expect(resource['key']).to eq(option.key)
      expect(resource['label']).to eq(option.label)
      expect(resource['default_value']).to eq(option.default_value)
      expect(resource['data_type']).to eq(option.data_type)
      expect(resource['select_options']).to eq(option.select_options)
    end
  end
end

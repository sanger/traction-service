require "rails_helper"

RSpec.describe 'TubesController', type: :request do

  let(:pipeline_name)       { 'pacbio' }
  let(:other_pipeline_name) { 'saphyr' }

  it_behaves_like 'tubes'

  context '#get?include=pools' do
    setup do
      pacbio_pool
      get "#{v1_pacbio_tubes_path}?include=pools", headers: json_api_headers
    end

    let(:pacbio_pool) { create :pacbio_pool, tube: create(:tube_with_pacbio_library) }

    it 'returns a response' do
      expect(response).to have_http_status(:success)
    end

    it 'included pools' do
      expect(find_included_resource(type: 'pools', id: pacbio_pool.id)).to be_present
    end
  end

end

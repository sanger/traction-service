require "rails_helper"

RSpec.describe 'SamplesController', type: :request do

  let(:headers) do
    {
      'Content-Type' => 'application/vnd.api+json',
      'Accept' => 'application/vnd.api+json'
    }
  end

  let(:body) do
    {
      data: {
        attributes: {
          name: 'Sample1'
        }
      }
    }
  end

  it 'can create a sample' do
    post v1_samples_path, params: body, headers: headers
    expect(response).to be_successful
    expect(response).to have_http_status(:created)
  end
  
end
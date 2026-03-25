# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authenticator Flipper feature flagging', type: :controller do
  let(:feature) { :y25_662_enable_request_authentication }

  # Dummy controller for testing
  controller(ApplicationController) do
    include Authenticator

    def index
      render plain: 'ok'
    end
  end

  before do
    routes.draw { get 'index' => 'anonymous#index' }
  end

  it 'skips authentication when Flipper flag is disabled' do
    allow(Flipper).to receive(:enabled?).with(feature).and_return(false)
    get :index
    expect(response.body).to eq('ok')
    expect(response).to have_http_status(:ok)
  end

  it 'calls authentication when Flipper flag is enabled' do
    allow(Flipper).to receive(:enabled?).with(feature).and_return(true)
    # No auth headers, so should be unauthorized
    get :index
    expect(response).to have_http_status(:unauthorized)
  end
end

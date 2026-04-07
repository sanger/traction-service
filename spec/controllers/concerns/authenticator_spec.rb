# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authenticator Flipper feature flagging', type: :controller do
  let(:feature) { :y25_662_enable_request_authentication }
  let(:feature_reject_unauthenticated) { :y25_662_reject_unauthenticated_requests }
  let(:api_application) { create(:api_application) }

  # Dummy controller for testing
  controller(ApplicationController) do
    # Define methods on a temporary class named AnonymousController.
    include Authenticator

    def index
      render plain: 'ok'
    end

    def create
      render plain: 'created'
    end
  end

  before do
    allow(Flipper).to receive(:enabled?).with(feature_reject_unauthenticated).and_return(true)

    routes.draw do
      # Define routes for the anonymous controller to test requests.
      get 'index' => 'anonymous#index'
      post 'create' => 'anonymous#create'
    end
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

  it 'authenticates a valid API key for GET requests' do
    allow(Flipper).to receive(:enabled?).with(feature).and_return(true)
    issued = api_application.rotate_api_key!

    request.headers['X-Traction-Client-Id'] = issued[:plaintext_key]

    allow(Rails.logger).to receive(:info)
    expect(Rails.logger).to receive(:info).with(match(/\[API KEY\] Key used/))
    get :index

    expect(response).to have_http_status(:ok)
    expect(issued[:api_key].reload.last_used_at).not_to be_nil
  end

  it 'rejects malformed API keys' do
    allow(Flipper).to receive(:enabled?).with(feature).and_return(true)

    request.headers['X-Traction-Client-Id'] = 'bad-format-key'
    get :index

    expect(response).to have_http_status(:unauthorized)
  end

  it 'permits non-GET requests authenticated by API key' do
    allow(Flipper).to receive(:enabled?).with(feature).and_return(true)
    issued = api_application.rotate_api_key!

    request.headers['X-Traction-Client-Id'] = issued[:plaintext_key]
    post :create

    expect(response).to have_http_status(:ok)
  end

  it 'authenticates a grace-period API key and sets a deprecation warning header' do
    allow(Flipper).to receive(:enabled?).with(feature).and_return(true)
    # Issue a key then rotate so the first key moves to grace_period
    issued = api_application.rotate_api_key!
    api_application.rotate_api_key!

    request.headers['X-Traction-Client-Id'] = issued[:plaintext_key]

    expect(Rails.logger).to receive(:warn).with(match(/\[API KEY\] Grace-period key used/))
    get :index

    expect(response).to have_http_status(:ok)
    expect(response.headers['X-Traction-Client-Id-Warning']).to match(/deprecated/i)
  end

  it 'rejects an expired API key' do
    allow(Flipper).to receive(:enabled?).with(feature).and_return(true)
    # Two rotations push the original key to expired
    issued = api_application.rotate_api_key!
    api_application.rotate_api_key!
    api_application.rotate_api_key!

    request.headers['X-Traction-Client-Id'] = issued[:plaintext_key]
    get :index

    expect(response).to have_http_status(:unauthorized)
  end

  it 'rejects an active API key when expires_at has passed' do
    allow(Flipper).to receive(:enabled?).with(feature).and_return(true)
    issued = api_application.rotate_api_key!
    issued[:api_key].update!(expires_at: 1.minute.ago)

    request.headers['X-Traction-Client-Id'] = issued[:plaintext_key]
    get :index

    expect(response).to have_http_status(:unauthorized)
  end

  it 'permits bearer-authenticated non-GET requests' do
    allow(Flipper).to receive(:enabled?).with(feature).and_return(true)

    request.headers['Authorization'] = 'Bearer valid-token'
    post :create

    expect(response).to have_http_status(:ok)
  end

  it 'permits non-expiring API keys' do
    allow(Flipper).to receive(:enabled?).with(feature).and_return(true)
    issued = api_application.rotate_api_key!(expires_at: nil)

    request.headers['X-Traction-Client-Id'] = issued[:plaintext_key]
    get :index

    expect(response).to have_http_status(:ok)
  end

  context 'unauthenticated request behavior' do
    it 'logs unauthenticated requests' do
      allow(Flipper).to receive(:enabled?).with(feature).and_return(true)
      allow(Flipper).to receive(:enabled?).with(feature_reject_unauthenticated).and_return(false)

      expect(Rails.logger).to receive(:warn).with(match(/\[AUTH\] Unauthenticated request/))
      get :index
    end

    it 'allows unauthenticated requests when reject flag is OFF' do
      allow(Flipper).to receive(:enabled?).with(feature).and_return(true)
      allow(Flipper).to receive(:enabled?).with(feature_reject_unauthenticated).and_return(false)

      get :index
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq('ok')
    end

    it 'rejects unauthenticated requests when reject flag is ON' do
      allow(Flipper).to receive(:enabled?).with(feature).and_return(true)
      allow(Flipper).to receive(:enabled?).with(feature_reject_unauthenticated).and_return(true)

      get :index
      expect(response).to have_http_status(:unauthorized)
    end

    it 'includes method, path, ip, and request_id in unauthenticated log' do
      allow(Flipper).to receive(:enabled?).with(feature).and_return(true)
      allow(Flipper).to receive(:enabled?).with(feature_reject_unauthenticated).and_return(false)

      expect(Rails.logger).to receive(:warn) do |message|
        expect(message).to include('[AUTH] Unauthenticated request')
        expect(message).to include('method=GET')
        expect(message).to include('path=/index')
        expect(message).to include('ip=')
        expect(message).to include('request_id=')
      end
      get :index
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authenticator', type: :controller do
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

  context 'GET requests' do
    it 'allows unauthenticated GET requests' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq('ok')
    end
  end

  context 'API key authentication' do
    it 'authenticates a valid API key for POST requests' do
      issued = api_application.rotate_api_key!

      request.headers['X-Traction-Client-Id'] = issued[:plaintext_key]

      allow(Rails.logger).to receive(:info)
      expect(Rails.logger).to receive(:info).with(include('[API KEY] Key used'))
      post :create

      expect(response).to have_http_status(:ok)
      expect(issued[:api_key].reload.last_used_at).not_to be_nil
    end

    it 'rejects malformed API keys' do
      request.headers['X-Traction-Client-Id'] = 'bad-format-key'
      post :create

      expect(response).to have_http_status(:unauthorized)
    end

    it 'permits non-GET requests authenticated by API key' do
      issued = api_application.rotate_api_key!

      request.headers['X-Traction-Client-Id'] = issued[:plaintext_key]
      post :create

      expect(response).to have_http_status(:ok)
    end

    it 'authenticates a grace-period API key and sets a deprecation warning header' do
      # Issue a key then rotate so the first key moves to grace_period
      issued = api_application.rotate_api_key!
      api_application.rotate_api_key!

      request.headers['X-Traction-Client-Id'] = issued[:plaintext_key]

      expect(Rails.logger).to receive(:warn).with(include('[API KEY] Grace-period key used'))
      post :create

      expect(response).to have_http_status(:ok)
      expect(response.headers['X-Traction-Client-Id-Warning']).to match(/deprecated/i)
    end

    it 'rejects an expired API key' do
      # Two rotations push the original key to expired
      issued = api_application.rotate_api_key!
      api_application.rotate_api_key!
      api_application.rotate_api_key!

      request.headers['X-Traction-Client-Id'] = issued[:plaintext_key]
      post :create

      expect(response).to have_http_status(:unauthorized)
    end

    it 'rejects an active API key when expires_at has passed' do
      issued = api_application.rotate_api_key!
      issued[:api_key].update!(expires_at: 1.minute.ago)

      request.headers['X-Traction-Client-Id'] = issued[:plaintext_key]
      post :create

      expect(response).to have_http_status(:unauthorized)
    end

    it 'permits non-expiring API keys' do
      issued = api_application.rotate_api_key!(expires_at: nil)

      request.headers['X-Traction-Client-Id'] = issued[:plaintext_key]
      post :create

      expect(response).to have_http_status(:ok)
    end
  end

  context 'unauthenticated requests' do
    it 'logs unauthenticated requests' do
      allow(Flipper).to receive(:enabled?).with(feature_reject_unauthenticated).and_return(false)

      expect(Rails.logger).to receive(:warn).with(include('[AUTH] Unauthenticated request'))
      post :create
    end

    it 'allows unauthenticated requests when reject flag is OFF' do
      allow(Flipper).to receive(:enabled?).with(feature_reject_unauthenticated).and_return(false)

      post :create
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq('created')
    end

    it 'rejects unauthenticated requests when reject flag is ON' do
      allow(Flipper).to receive(:enabled?).with(feature_reject_unauthenticated).and_return(true)

      post :create
      expect(response).to have_http_status(:unauthorized)
    end

    it 'includes method, path, ip, and request_id in unauthenticated log' do
      allow(Flipper).to receive(:enabled?).with(feature_reject_unauthenticated).and_return(false)

      expect(Rails.logger).to receive(:warn) do |message|
        expect(message).to include('[AUTH] Unauthenticated request')
        expect(message).to include('method=POST')
        expect(message).to include('path=/create')
        expect(message).to include('ip=')
        expect(message).to include('request_id=')
      end
      post :create
    end
  end

  context 'bearer token authentication' do
    let(:okta_provider_double) do
      instance_double(AuthProviders::OktaJwtProvider).tap do |double|
        allow(double).to receive(:valid?) do |token|
          token.present? && token == 'valid-token'
        end
      end
    end

    before do
      # Inject the test double for OktaJwtProvider
      allow(AuthProviders::OktaJwtProvider).to receive(:new).and_return(okta_provider_double)
    end

    it 'rejects an invalid bearer token' do
      request.headers['Authorization'] = 'Bearer '
      post :create
      expect(response).to have_http_status(:unauthorized)
    end

    it 'rejects a bearer token with invalid credentials' do
      request.headers['Authorization'] = 'Bearer invalid-token'
      post :create
      expect(response).to have_http_status(:unauthorized)
    end

    it 'permits bearer-authenticated non-GET requests with a valid token' do
      request.headers['Authorization'] = 'Bearer valid-token'
      post :create
      expect(response).to have_http_status(:ok)
    end
  end
end

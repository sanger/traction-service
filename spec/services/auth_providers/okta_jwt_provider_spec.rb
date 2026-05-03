# frozen_string_literal: true

require 'webmock/rspec'
require 'rails_helper'
require 'jwt'

# Simple JWT validation flow
# traction-service does not need to contact Okta for every token validation.
# 1. Initial JWKS Fetch
#  - The first time a JWT is received from the client, it fetches the JKWS
#    (JSON Web Key Set) from Okta's JWKS endpoint.
#  - The JKWS endpoint returns a set of public keys needed to verify the JWT's
#    signature. This is because Okta may have multiple active signing keys at
#    once, especially during key rotation.
# 2. Local validation
#  - The service uses the fetched public keys to validate the JWT locally. For
#    a specific JWT, only one public key (identified by the "kid" in the JWT
#    header) is used to verify the token's signature.
#  - The service also checks claims like "iss" (issuer) and "aud" (audience) to
#    ensure the token is valid.
# 3. No per-request Okta calls
#  - After the initial JKWS fetch, the service caches the keys.
#  - For subsequent tokens, validation is entirely local, the service does not
#    need to contact Okta again unless the key changes (e.g., key rotation).
#
describe AuthProviders::OktaJwtProvider do
  # Ensure WebMock disables external network connections (except localhost) for
  # test isolation, and restore original state after tests.
  around do |example|
    webmock_was_allowing_net_connect = WebMock.net_connect_allowed?
    WebMock.disable_net_connect!(allow_localhost: true) if webmock_was_allowing_net_connect
    example.run
    WebMock.allow_net_connect! if webmock_was_allowing_net_connect
  end

  # The 'issuer' claim identifies the principal that issued the JWT.
  # In production, this would be the Okta domain (e.g., https://sanger.okta.com)
  # In tests, it is used for initialising the provider and generating the payload.
  let(:issuer) { 'http://localhost:3000' }

  # The 'audience' claim identifies the recipients that the JWT is intended for.
  # This is normally the API's identifier (e.g., 'api://default' or a custom
  # string). However, in production, 'https://sanger.okta.com' is used.
  let(:audience) { 'test-audience' }

  # The 'kid' (Key ID) claim in the JWT header identifies which key was used to
  # sign the token. This allows the service to select the correct public key
  # from the JWKS set for signature verification.
  let(:kid) { 'test-key' }

  # In tests, we generate a new RSA key pair for signing and verifying JWTs,
  # simulating how Okta would sign tokens.
  let(:private_key) { OpenSSL::PKey::RSA.generate(2048) }

  # The public key is used for verifying the JWT signature. It is published via
  # JWKS endpoint to verify tokens signed with the private key.
  let(:public_key) { private_key.public_key }

  # The JWKS (JSON Web Key Set) is a JSON structure that contains the public keys
  # used to verify JWT signatures. This matches the format Okta uses to publish
  # its public keys. We will stub the JWKS endpoint to return this set of keys
  # for our tests.
  let(:jwks) do
    jwk = JWT::JWK.create_from(public_key, kid: kid)
    { 'keys' => [jwk.export] }
  end

  # The client_id (Okta 'cid' claim) identifies the client application the
  # token was issued for. It varies by environment (e.g., different for UAT,
  # production, etc.).
  let(:client_id) { 'test-client-id' }

  # The URI for the JWKS (JSON Web Key Set) endpoint. In production, this would
  # point to the Okta JWKS endpointl, https://sanger.okta.com/oauth2/v1/keys
  let(:jwks_uri) { 'http://localhost:3000/jwks' }
  let(:provider) { described_class.new(issuer:, audience:, jwks_uri:, client_id:) }

  # The expiration time for the JWT, set to 1 hour from now. This is used in the
  # payload.
  let(:expiration) { 1.hour.from_now.to_i }

  # The JWT header to encode the token with. It includes the 'kid' to identify
  # the signing key in the JKWS response.
  let(:jwt_header) do
    {
      kid: kid,
      typ: 'application/okta-internal-at+jwt',
      alg: 'RS256'
    }
  end

  let(:jwt_payload) do
    {
      ver: 1,
      jti: 'test-jti',
      iss: issuer,
      aud: audience,
      sub: 'test-user@example.com',
      iat: Time.now.to_i,
      exp: 1.hour.from_now.to_i,
      cid: client_id,
      uid: 'test-user-id',
      scp: %w[openid profile email],
      auth_time: Time.now.to_i
    }
  end

  before do
    Rails.cache.clear
    stub_request(:get, jwks_uri).to_return(
      status: 200,
      body: jwks.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  it 'validates a token with correct claims and signature' do
    token = JWT.encode(jwt_payload, private_key, 'RS256', jwt_header)
    expect(provider.valid?(token)).to be true
  end

  it 'rejects a token with wrong audience' do
    payload = jwt_payload.merge(aud: 'wrong-audience')
    token = JWT.encode(payload, private_key, 'RS256', jwt_header)
    expect(provider.valid?(token)).to be false
  end

  it 'rejects a token with expired exp claim' do
    payload = jwt_payload.merge(exp: 1.hour.ago.to_i)
    token = JWT.encode(payload, private_key, 'RS256', jwt_header)
    expect(provider.valid?(token)).to be false
  end

  it 'rejects a token missing the exp claim' do
    payload = jwt_payload.dup
    payload.delete(:exp)
    token = JWT.encode(payload, private_key, 'RS256', jwt_header)
    expect(provider.valid?(token)).to be false
  end

  it 'rejects a token with wrong signature' do
    # Sign the JWT with a different private key to simulate an invalid signature
    other_key = OpenSSL::PKey::RSA.generate(2048)
    token = JWT.encode(jwt_payload, other_key, 'RS256', jwt_header)
    expect(provider.valid?(token)).to be false
  end

  it 'rejects a token signed with an invalid algorithm (HS256)' do
    # Okta seems to be using the RS256 algorithm.
    token = JWT.encode(jwt_payload, 'secret', 'HS256', jwt_header.merge(alg: 'HS256'))
    expect(provider.valid?(token)).to be false
  end

  it 'returns false if a network error occurs when fetching JWKS' do
    token = JWT.encode(jwt_payload, private_key, 'RS256', jwt_header)
    # Simulate a network error (SocketError) when fetching JWKS
    stub_request(:get, jwks_uri).to_raise(SocketError)
    expect(provider.valid?(token)).to be false
  end

  it 'returns false if JWKS endpoint returns invalid JSON' do
    token = JWT.encode(jwt_payload, private_key, 'RS256', jwt_header)
    stub_request(:get, jwks_uri).to_return(status: 200, body: 'not a json', headers: { 'Content-Type' => 'application/json' })
    expect(provider.valid?(token)).to be false
  end

  it 'returns false if JWKS endpoint returns an empty keys array' do
    token = JWT.encode(jwt_payload, private_key, 'RS256', jwt_header)
    stub_request(:get, jwks_uri).to_return(status: 200, body: { keys: [] }.to_json, headers: { 'Content-Type' => 'application/json' })
    expect(provider.valid?(token)).to be false
  end

  it 'returns false if JWKS URI is invalid' do
    invalid_provider = described_class.new(
      issuer: issuer,
      audience: audience,
      jwks_uri: 'http://invalid^uri',
      client_id: client_id
    )
    token = JWT.encode(jwt_payload, private_key, 'RS256', jwt_header)
    expect(invalid_provider.valid?(token)).to be false
  end

  it 'logs an error when a network error occurs' do
    token = JWT.encode(jwt_payload, private_key, 'RS256', jwt_header)
    stub_request(:get, jwks_uri).to_raise(SocketError)
    expect(Rails.logger).to receive(:error).with(include('[OKTA JWT] Validation failure: SocketError'))
    provider.valid?(token)
  end

  it 'logs error with short token without raising' do
    short_token = 'abc'
    stub_request(:get, jwks_uri).to_raise(SocketError)
    expect(Rails.logger).to receive(:error).with(include('token_prefix=abc'))
    provider.valid?(short_token)
  end

  it 'uses cached JWKS for subsequent validations' do
    token = JWT.encode(jwt_payload, private_key, 'RS256', jwt_header)
    # Expect only one network request for JWKS
    stub = stub_request(:get, jwks_uri).to_return(status: 200, body: jwks.to_json, headers: { 'Content-Type' => 'application/json' })
    expect(provider.valid?(token)).to be true
    expect(stub).to have_been_requested.once
  end

  it 'rejects a token with an invalid issuer' do
    payload = jwt_payload.merge(iss: 'https://invalid-issuer.example.com')
    token = JWT.encode(payload, private_key, 'RS256', jwt_header)
    expect(provider.valid?(token)).to be false
  end

  it 'rejects a token with a future iat (issued at) claim' do
    payload = jwt_payload.merge(iat: 1.hour.from_now.to_i)
    token = JWT.encode(payload, private_key, 'RS256', jwt_header)
    expect(provider.valid?(token)).to be false
  end

  it 'accepts a token with exp just within the leeway' do
    payload = jwt_payload.merge(exp: 2.seconds.ago.to_i)
    token = JWT.encode(payload, private_key, 'RS256', jwt_header)
    expect(provider.valid?(token)).to be true
  end

  it 'rejects a token with exp just outside the leeway' do
    payload = jwt_payload.merge(exp: 4.seconds.ago.to_i)
    token = JWT.encode(payload, private_key, 'RS256', jwt_header)
    expect(provider.valid?(token)).to be false
  end

  it 'rejects a token with a kid not present in JWKS' do
    missing_kid = 'missing-key-id'
    header_with_missing_kid = jwt_header.merge(kid: missing_kid)
    token = JWT.encode(jwt_payload, private_key, 'RS256', header_with_missing_kid)
    # JWKS does not contain the missing_kid
    stub_request(:get, jwks_uri).to_return(status: 200, body: jwks.to_json, headers: { 'Content-Type' => 'application/json' })
    expect(provider.valid?(token)).to be false
  end

  it 'refetches JWKS on kid miss and validates token after key rotation' do
    initial_token = JWT.encode(jwt_payload, private_key, 'RS256', jwt_header)
    initial_stub = stub_request(:get, jwks_uri).to_return(
      status: 200,
      body: jwks.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )

    expect(provider.valid?(initial_token)).to be true
    expect(initial_stub).to have_been_requested.once

    rotated_kid = 'rotated-key'
    rotated_private_key = OpenSSL::PKey::RSA.generate(2048)
    rotated_jwks = {
      'keys' => [JWT::JWK.create_from(rotated_private_key.public_key, kid: rotated_kid).export]
    }

    stub_request(:get, jwks_uri).to_return(
      status: 200,
      body: rotated_jwks.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )

    rotated_token = JWT.encode(jwt_payload, rotated_private_key, 'RS256', jwt_header.merge(kid: rotated_kid))
    expect(provider.valid?(rotated_token)).to be true
    expect(a_request(:get, jwks_uri)).to have_been_made.twice
  end

  it 'fetches JWKS again after cache expiration' do
    token = JWT.encode(jwt_payload, private_key, 'RS256', jwt_header)
    stub = stub_request(:get, jwks_uri).to_return(status: 200, body: jwks.to_json, headers: { 'Content-Type' => 'application/json' })
    expect(provider.valid?(token)).to be true
    expect(stub).to have_been_requested.once

    # Simulate cache expiration
    Rails.cache.delete([:okta_jwks, jwks_uri])
    expect(provider.valid?(token)).to be true
    expect(stub).to have_been_requested.twice
  end

  it 'returns false if JWKS endpoint returns a 500 error' do
    token = JWT.encode(jwt_payload, private_key, 'RS256', jwt_header)
    stub_request(:get, jwks_uri).to_return(status: 500, body: 'Internal Server Error')
    expect(provider.valid?(token)).to be false
  end

  it 'rejects a token with an invalid client_id (cid claim)' do
    payload = jwt_payload.merge(cid: 'wrong-client-id')
    token = JWT.encode(payload, private_key, 'RS256', jwt_header)
    expect(provider.valid?(token)).to be false
  end
end

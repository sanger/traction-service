# frozen_string_literal: true

require 'jwt'
require 'net/http'
require 'uri'
require 'json'

module AuthProviders
  # Validates JWTs issued by Okta using the JWKS endpoint
  class OktaJwtProvider
    def initialize(issuer:, audience:, jwks_uri:)
      @issuer = issuer
      @audience = audience
      @jwks_uri = jwks_uri
      @cached_keys = nil
      @last_fetch = nil
    end

    # Validates the JWT and returns the decoded payload if valid, or nil if invalid
    def valid?(token)
      payload, _header = decode(token)
      payload.present?
    rescue JWT::DecodeError, JWT::VerificationError, JWT::ExpiredSignature
      false
    end

    private

    def decode(token)
      JWT.decode(token, nil, true,
                 algorithms: ['RS256'],
                 jwks: jwks_loader,
                 iss: @issuer,
                 verify_iss: true,
                 aud: @audience,
                 verify_aud: true)
    end

    def jwks_loader
      @jwks_loader ||= lambda do |_options|
        # Cache keys for 5 minutes
        if @cached_keys.nil? || @last_fetch.nil? || (Time.current - @last_fetch) > 300
          @cached_keys = fetch_jwks
          @last_fetch = Time.current
        end
        @cached_keys
      end
    end

    def fetch_jwks
      uri = URI(@jwks_uri)
      response = Net::HTTP.get(uri)
      jwks = JSON.parse(response)
      JWT::JWK::Set.new(jwks)
    end
  end
end

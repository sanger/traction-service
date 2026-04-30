# frozen_string_literal: true

require 'jwt'
require 'net/http'
require 'uri'
require 'json'
# Authentication provider implementations, e.g. Okta JWT validation
module AuthProviders
  # Validates JWTs issued by Okta using the JWKS endpoint
  class OktaJwtProvider
    # Initializes the OktaJwtProvider with issuer, audience, and JWKS URI.
    #
    # @param issuer [String] The expected issuer for JWT validation
    # @param audience [String] The expected audience for JWT validation
    # @param jwks_uri [String] The URI to fetch the JWKS (Key Set) from Okta
    def initialize(issuer:, audience:, jwks_uri:)
      @issuer = issuer
      @audience = audience
      @jwks_uri = jwks_uri
      @cached_keys = nil
      @last_fetch = nil
    end

    # Validates the JWT and returns true if valid, false otherwise.
    #
    # @param token [String] The JWT token to validate
    # @return [Boolean] true if the token is valid, false otherwise
    # rubocop:disable Metrics/MethodLength
    def valid?(token)
      payload, _header = decode(token)
      payload.present?
    rescue JWT::DecodeError,
           JWT::JWK::Set::KidNotFound,
           JWT::JWK::Set::InvalidJWKError,
           JSON::ParserError,
           URI::InvalidURIError,
           SocketError,
           Errno::ECONNREFUSED,
           Errno::ETIMEDOUT,
           Errno::EHOSTUNREACH,
           Net::OpenTimeout,
           Net::ReadTimeout => e
      Rails.logger.error(
        "[OKTA JWT] Validation failure: #{e.class.name}: #{e.message} " \
        "token_prefix=#{token[0, 10]}... token_length=#{token.length}"
      )
      false
    end
    # rubocop:enable Metrics/MethodLength

    private

    # Decodes and verifies the JWT using the configured issuer, audience, and
    # JWKS endpoint.
    #
    # @param token [String] The JWT token to decode and verify
    # @return [Array] The decoded payload and header
    # @raise [JWT::ExpiredSignature] if the token is expired (exp claim)
    # @raise [JWT::ImmatureSignature] if the token is not valid yet (nbf claim)
    # @raise [JWT::InvalidIatError] if the issued at claim (iat) is invalid
    # @raise [JWT::InvalidIssuerError] if the issuer claim (iss) is invalid
    # @raise [JWT::InvalidAudError] if the audience claim (aud) is invalid
    # @raise [JWT::VerificationError] if the signature is invalid
    # @raise [JWT::DecodeError] for all other decode errors (malformed, etc.)
    # rubocop:disable Metrics/MethodLength
    def decode(token)
      JWT.decode(
        token,
        nil, # key: look up using jwks_loader
        true, # verify all: verify the signature and all claims in the options
        verify_iss: true, # verify issuer
        verify_aud: true, # verify audience
        verify_expiration: true,  # verify expiration time
        verify_not_before: true,  # verify not before time
        verify_iat: true, # verify issued at time
        verify_jti: false, # don't verify JWT ID; not known beforehand
        verify_sub: false, # don't verify subject; not known beforehand
        leeway: 3, # tolerance for clock skew in seconds for expiration time
        algorithms: ['RS256'],
        iss: @issuer,
        aud: @audience,
        jwks: jwks_loader
      )
    end
    # rubocop:enable Metrics/MethodLength

    # Returns a lambda for loading JWKS (JSON Web Key Set) from Okta.
    # This lambda is used by the JWT gem to look up the correct public key for
    # signature verification. The keys are cached for 5 minutes to avoid
    # unnecessary network requests and improve performance.
    #
    # @return [Proc] a lambda that fetches and returns the JWKS
    def jwks_loader
      @jwks_loader ||= lambda do |_options|
        Rails.cache.fetch([:okta_jwks, @jwks_uri], expires_in: 5.minutes) do
          fetch_jwks
        end
      end
    end

    # Fetches the JWKS (JSON Web Key Set) from the configured Okta JWKS URI.
    # Parses the JSON response and returns a JWT::JWK::Set for use in
    # signature verification. This method is called by the JWKS loader and is
    # wrapped in a cache.
    #
    # @return [JWT::JWK::Set] the JWKS set for signature verification
    # @raise [URI::InvalidURIError] if @jwks_uri is not a valid URI
    # @raise [SocketError, Errno::ECONNREFUSED, Errno::ETIMEDOUT,
    #   Errno::EHOSTUNREACH, Net::OpenTimeout, Net::ReadTimeout] for network
    #   errors when fetching the JWKS
    # @raise [JSON::ParserError] if the HTTP response is not valid JSON
    # @raise [JWT::JWK::Set::KidNotFound, JWT::JWK::Set::InvalidJWKError] if
    #   the JWKS is invalid or missing required fields
    # @raise [StandardError] for any other unexpected error
    def fetch_jwks
      uri = URI(@jwks_uri)
      response = Net::HTTP.get(uri)
      jwks = JSON.parse(response)
      JWT::JWK::Set.new(jwks)
    end
  end
end

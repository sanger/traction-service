# frozen_string_literal: true

require 'jwt'
require 'net/http'
require 'uri'
require 'json'

# Authentication provider implementations, e.g. Okta JWT validation
# @see https://github.com/jwt/ruby-jwt
module AuthProviders
  # Validates JWTs issued by Okta using the JWKS endpoint
  class OktaJwtProvider < BearerTokenProvider
    # Network-related failures that can occur while fetching JWKS.
    #
    # @return [Array<Class>] exception classes treated as validation failures
    NETWORK_ERRORS = [
      SocketError,
      Errno::ECONNREFUSED,
      Errno::ETIMEDOUT,
      Errno::EHOSTUNREACH,
      Net::OpenTimeout,
      Net::ReadTimeout
    ].freeze

    # All failures handled by #valid? as authentication validation failures.
    #
    # @return [Array<Class>] exception classes rescued and logged by #valid?
    VALIDATION_ERRORS = [
      JWT::DecodeError,
      JSON::ParserError,
      URI::InvalidURIError,
      *NETWORK_ERRORS
    ].freeze

    # Initializes the OktaJwtProvider with issuer, audience, and JWKS URI.
    #
    # @param issuer [String] The expected issuer for JWT validation
    # @param audience [String] The expected audience for JWT validation
    # @param jwks_uri [String] The URI to fetch the JWKS (Key Set) from Okta
    # rubocop:disable Lint/MissingSuper
    def initialize(issuer:, audience:, jwks_uri:, client_id:)
      @issuer = issuer
      @audience = audience
      @jwks_uri = jwks_uri
      @client_id = client_id
    end
    # rubocop:enable Lint/MissingSuper

    # Validates the JWT and returns true if valid, false otherwise.
    #
    # This method rescues all exceptions listed in VALIDATION_ERRORS, logs the
    # failure reason, and returns false so authentication failures do not bubble
    # up, while allowing unexpected errors to raise normally.
    #
    # @param token [String] The JWT token to validate
    # @return [Boolean] true if the token is valid, false otherwise
    def valid?(token)
      payload, _header = decode(token) # verify signature and claims; raises if invalid
      return false if payload.blank?
      return false unless valid_client_id?(payload)

      true
    rescue *VALIDATION_ERRORS => e
      Rails.logger.error(
        "[OKTA JWT] Validation failure: #{e.class.name}: #{e.message} " \
        "token_prefix=#{token[0, 10]}... token_length=#{token.length}"
      )
      false
    end

    private

    # Validates that the token client_id claim matches the configured client.
    #
    # Logs a validation error when the cid claim does not match.
    #
    # @param payload [Hash] the decoded JWT payload
    # @return [Boolean] true if the cid claim matches, false otherwise
    def valid_client_id?(payload)
      return true if payload['cid'] == @client_id

      Rails.logger.error(
        "[OKTA JWT] Invalid client_id: expected #{@client_id}, " \
        "got #{payload['cid']}"
      )
      false
    end

    # Decodes and verifies the JWT using the configured issuer, audience, and
    # JWKS endpoint.
    #
    # @param token [String] The JWT token to decode and verify
    # @return [Array] The decoded payload and header
    # @raise [JWT::DecodeError] if token verification or claim validation fails
    # @see #fetch_jwks for additional errors that may be raised when fetching JWKS
    # rubocop:disable Metrics/MethodLength
    def decode(token)
      JWT.decode(
        token,
        nil, # key: look up using jwks_loader
        true, # verify all: verify the signature and all claims in the options
        verify_iss: true, # verify issuer
        verify_aud: true, # verify audience
        verify_expiration: true,  # verify expiration time
        verify_not_before: false, # don't verify not before time; not present
        verify_iat: true, # verify issued at time
        verify_jti: false, # don't verify JWT ID; not known beforehand
        verify_sub: false, # don't verify subject; not known beforehand
        leeway: 3, # tolerance for clock skew in seconds for expiration time
        algorithms: ['RS256'],
        iss: @issuer,
        aud: @audience,
        jwks: jwks_loader,
        required_claims: %w[aud exp iat iss] # check presence
      )
    end
    # rubocop:enable Metrics/MethodLength

    # Returns a lambda for loading JWKS (JSON Web Key Set) from Okta.
    # This lambda is used by the JWT gem to look up the correct public key for
    # signature verification. The keys are cached for 5 minutes to avoid
    # unnecessary network requests and improve performance. It also supports
    # cache invalidation when a key ID (kid) is not found, which can happen
    # when Okta rotates keys.
    # @see https://github.com/jwt/ruby-jwt#json-web-key-jwk
    # @return [Proc] a lambda that fetches and returns the JWKS
    def jwks_loader
      lambda do |options|
        cache_key = [:okta_jwks, @jwks_uri]

        # When JWT cannot find a key id (kid), it invokes the loader *again*
        # with invalidate/kid_not_found so we can refresh stale keys.
        if options&.[](:invalidate) || options&.[](:kid_not_found)
          jwks = fetch_jwks
          Rails.cache.write(cache_key, jwks, expires_in: 5.minutes)
          next jwks
        end

        # Normal case: try to read from cache, fetch if not present
        Rails.cache.fetch(cache_key, expires_in: 5.minutes) { fetch_jwks }
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
    # @raise [JWT::JWKError] if the JWKS is invalid or missing required fields
    def fetch_jwks
      uri = URI(@jwks_uri)
      response = Net::HTTP.get(uri)
      jwks = JSON.parse(response)
      JWT::JWK::Set.new(jwks)
    end
  end
end

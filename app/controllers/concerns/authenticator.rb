# frozen_string_literal: true

# Plug this to authenticate requests using either Bearer tokens or API keys.
#
# Supports two authentication methods:
# 1. Bearer tokens (JWT/OAuth2, for future Identity Provider integration)
# 2. API keys (via X-Traction-Client-Id header, for programmatic access)
#
# Key usage is logged, and grace-period keys trigger deprecation warnings.
#
# @example Include in a controller
#   class ApiController < ApplicationController
#     include Authenticator
#   end
#
module Authenticator
  extend ActiveSupport::Concern

  # Using headers instead of env, HTTP_X_TRACTION_CLIENT_ID in Rails.
  API_KEY_HEADER = 'X-Traction-Client-Id'
  BEARER = 'Bearer'

  included do
    before_action :authenticate_request!
  end

  private

  # Main authentication entry point for all controller actions.
  #
  # Routes requests through appropriate authentication strategy:
  # 1. Bearer token (if Authorization header present)
  # 2. API key (if X-Traction-Client-Id header present)
  # 3. Denied (if neither present)
  #
  # @return [void]
  def authenticate_request!
    return unless Flipper.enabled?(:y25_662_enable_request_authentication)

    if bearer_token_present?
      authenticate_bearer!
    elsif api_key_present?
      authenticate_api_key!
    else
      handle_unauthenticated!
    end
  end

  # Checks if the Authorization header contains a Bearer token (JWT/OAuth2 style).
  #
  # @return [Boolean] true if Bearer token is present, false otherwise
  def bearer_token_present?
    request.headers['Authorization']&.start_with?(BEARER)
  end

  # Authenticates a request using a Bearer token from the Authorization header.
  #
  # @return [void]
  def authenticate_bearer!
    token = bearer_token
    return render_unauthorized('Invalid Bearer token') unless valid_bearer_token?(token)

    @current_auth = :bearer
  end

  # Extracts the token value from the Authorization header in the format "Bearer <token>".
  #
  # @return [String, nil] the token string if present, nil otherwise
  def bearer_token
    auth = request.headers['Authorization']
    return nil unless auth&.start_with?(BEARER)

    token = auth[BEARER.size..].strip
    token.presence
  end

  # Validates a Bearer token using the configured provider abstraction.
  #
  # @param token [String] the token to validate
  # @return [Boolean] true if token is valid
  def valid_bearer_token?(token)
    bearer_token_provider.valid?(token)
  end

  # Returns the configured Bearer token provider (Okta, etc.)
  #
  # @return [AuthProviders::BearerTokenProvider]
  def bearer_token_provider
    @bearer_token_provider ||= AuthProviders.build_bearer_token_provider
  end

  # Checks if an API key is present in the X-Traction-Client-Id header.
  #
  # @return [Boolean] true if header is present, false otherwise
  def api_key_present?
    request.headers[API_KEY_HEADER].present?
  end

  # Authenticates a request using an API key from the X-Traction-Client-Id header.
  #
  # Validates that the key:
  # - Exists in the database (via SHA-256 digest lookup)
  # - Is in active or grace_period status
  # - Has not passed expires_at (when expires_at is present)
  #
  # Updates last_used_at timestamp and logs grace-period usage.
  # If in grace period, sets deprecation warning header.
  # Renders 401 Unauthorized if key is invalid.
  #
  # @return [void]
  def authenticate_api_key!
    raw_key = request.headers[API_KEY_HEADER]

    key = ApiKey.find_by(key_digest: Digest::SHA256.hexdigest(raw_key))
    return render_unauthorized('API key not found') unless key

    # active and grace_period keys are both valid; expired is rejected
    return render_unauthorized('API key not valid') unless key.active? || key.grace_period?
    return render_unauthorized('API key expired') if api_key_expired?(key)

    log_key_usage(key)

    # Warn the caller if their key is in the grace period so they know to rotate
    add_grace_period_warning_header(key)

    @current_auth = :api_key
    @current_api_client = key.api_application
  end

  # Handles requests with no valid credentials.
  #
  # GET requests are blanked allowed.
  # This can be changed in the future but it was decided because of known use cases:
  # - Limber check for tube creation
  # - Traction-ui sample sheet generation link
  #
  # @return [void]
  def handle_unauthenticated!
    return if request.get?

    log_message = '[AUTH] Unauthenticated request ' \
                  "method=#{request.request_method} " \
                  "path=#{request.fullpath} " \
                  "ip=#{request.remote_ip} " \
                  "request_id=#{request.request_id}"
    Rails.logger.warn(log_message)

    return unless Flipper.enabled?(:y25_662_reject_unauthenticated_requests)

    render_unauthorized('Authentication required')
  end

  # Logs API key usage and warns if key is in grace period.
  #
  # Updates the key's last_used_at timestamp and logs, logs an info message
  # for the active key or a warning message if the key is in grace_period status.
  #
  # @param key [ApiKey] the API key that was used
  # @return [void]
  def log_key_usage(key)
    key.update(last_used_at: Time.current)

    if key.grace_period?
      log_message = '[API KEY] Grace-period key used ' \
                    "(id=#{key.id}, status=#{key.status}, expires_at=#{key.expires_at})"
      Rails.logger.warn(log_message)
    else
      log_message = '[API KEY] Key used ' \
                    "(id=#{key.id}, status=#{key.status}, expires_at=#{key.expires_at})"
      Rails.logger.info(log_message)
    end
  end

  # Sets a response header warning when a grace-period API key is used.
  #
  # @param key [ApiKey] the API key used for authentication
  # @return [void]
  def add_grace_period_warning_header(key)
    return unless key.grace_period?

    expires_str = key.expires_at&.strftime('%Y-%m-%d') || 'soon'
    warning_message =
      "The API key used is deprecated and will be deactivated on #{expires_str}"
    response.set_header('X-Traction-Client-Id-Warning', warning_message)
  end

  # Returns true when key has an expires_at timestamp in the past.
  #
  # @param key [ApiKey]
  # @return [Boolean]
  def api_key_expired?(key)
    key.expires_at.present? && key.expires_at.past?
  end

  # Renders a 401 Unauthorized response.
  #
  # @param message [String] error message to include in response
  # @return [void]
  def render_unauthorized(message)
    render json: { error: message }, status: :unauthorized
  end
end

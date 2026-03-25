# frozen_string_literal: true

# Plug this to authenticate requests using either Bearer tokens
# (e.g. Identity Provider) or API keys.
# TODO: handle paths v1 and flipper
# TODO: UI needs to start with token flow and possibly check before each request
# TODO: put behind flipper feature flag
# TODO: migrations and models for api apps and api keys tables
module Authenticator
  extend ActiveSupport::Concern

  # Using headers instead of env, HTTP_X_TRACTION_CLIENT_ID in Rails.
  API_KEY_HEADER = 'X-Traction-Client-Id'

  included do
    before_action :authenticate_request! # preceed all controller actions
  end

  private # not controller public actions

  # Main authentication entry point
  def authenticate_request!
    if bearer_token_present? # identity provider check
      authenticate_bearer!
    elsif api_key_present? # api key check
      authenticate_api_key!
      enforce_api_key_permissions! # story requires API keys to be for GET.
    else
      # XXX: Should allow for now, or make a flipper flag
      handle_unauthenticated! # return 401
    end
  end

  # Identity provider authentication
  def bearer_token_present?
    request.headers['Authorization']&.start_with?('Bearer ')
  end

  def authenticate_bearer!
    token = bearer_token

    return render_unauthorized('Invalid Bearer token') unless valid_bearer_token?(token)

    @current_auth = :bearer
  end

  def bearer_token
    # extract token from "Bearer <token>" format
    request.headers['Authorization']&.split&.last
  end

  def valid_bearer_token?(token)
    # TODO: plug real Bearer validation here, i.e. Identity Provider, JWT, etc.
    token.present?
  end

  # API key authentication
  def api_key_present?
    request.headers[API_KEY_HEADER].present?
  end

  def authenticate_api_key!
    raw_key = request.headers[API_KEY_HEADER]

    # XXX: prefix or not? Maybe helpful for rotation, and possible key types.
    prefix, secret = parse_api_key(raw_key)
    return render_unauthorized('Invalid API key format') unless prefix

    key = ApiKey.find_by(prefix: prefix)
    return render_unauthorized('API key not found') unless key

    return render_unauthorized('API key revoked') unless key.active?

    return render_unauthorized('Invalid API key') unless valid_secret?(secret, key.key_hash)

    log_key_usage(key)

    @current_auth = :api_key
    @current_api_client = key.api_application
  end

  def parse_api_key(raw_key)
    # assumes format "prefix.secret", where prefix is stored in DB and secret is hashed
    parts = raw_key.split('.', 2)
    return [nil, nil] unless parts.size == 2

    parts
  end

  def valid_secret?(secret, key_hash)
    # TODO: salt
    BCrypt::Password.new(key_hash) == secret
  end

  # story says API keys should be read-only
  def enforce_api_key_permissions!
    return unless @current_auth == :api_key

    return if request.get?

    render_forbidden('API keys are read-only')
  end

  # transitional
  def handle_unauthenticated!
    # Y25-661: allow GET temporarily
    return if request.get?

    render_unauthorized('Authentication required')
  end

  # logging
  def log_key_usage(key)
    key.update(:last_used_at, Time.current)

    # Soft "grace period" from rotation design from Y25-575
    # XXX: checking against a magic number
    return unless key.created_at < 3.months.ago

    Rails.logger.warn("[API KEY] Old key used: #{key.id}")
  end

  # responses
  def render_unauthorized(message)
    render json: { error: message }, status: :unauthorized
  end

  def render_forbidden(message)
    render json: { error: message }, status: :forbidden
  end
end

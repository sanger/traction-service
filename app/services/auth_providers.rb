# frozen_string_literal: true

# Provides authentication provider factory methods and shared logic for bearer
# token providers.
module AuthProviders
  # Loads the authentication provider config and returns an instance of the
  # appropriate provider. Currently supports Okta JWT provider.
  #
  # @return [AuthProviders::BearerTokenProvider] an instance of the configured
  #   Bearer token provider
  # @raise [RuntimeError] if the provider is unknown
  def self.build_bearer_token_provider
    config = Rails.application.config.auth.with_indifferent_access
    case config[:provider]
    when 'okta'
      AuthProviders::OktaJwtProvider.new(
        issuer: config[:issuer],
        audience: config[:audience],
        jwks_uri: config[:jwks_uri],
        client_id: config[:client_id]
      )
    else
      raise "Unknown auth provider: #{config[:provider]}"
    end
  end
end

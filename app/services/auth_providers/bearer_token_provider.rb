# frozen_string_literal: true

# Provides interface for authentication providers used for bearer token
# validation.
module AuthProviders
  # Interface for Bearer token providers
  class BearerTokenProvider
    # Checks if the given bearer token is valid.
    #
    # Implementations should perform all necessary validation (e.g., signature,
    # claims).
    #
    # @param _token [String] the bearer token to validate
    # @return [Boolean] true if the token is valid, false otherwise
    # @raise [NotImplementedError] if not implemented by subclass
    def valid?(_token)
      raise NotImplementedError, 'Subclasses must implement valid?'
    end
  end
end

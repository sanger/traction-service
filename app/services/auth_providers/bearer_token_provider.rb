# frozen_string_literal: true

module AuthProviders
  # Interface for Bearer token providers
  class BearerTokenProvider
    def valid?(_token)
      raise NotImplementedError, 'Subclasses must implement valid?'
    end
  end
end

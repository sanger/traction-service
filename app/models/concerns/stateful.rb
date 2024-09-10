# frozen_string_literal: true

# Stateful
module Stateful
  extend ActiveSupport::Concern

  included do
    # Note that these values are referenced in the GraphQL enum for Run State.
    enum :state, { pending: 0, started: 1, completed: 2, cancelled: 3 }
  end
end

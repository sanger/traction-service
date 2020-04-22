# frozen_string_literal: true

# Receptacle
module Receptacle
  extend ActiveSupport::Concern

  included do
    has_one :container, as: :receptacle, dependent: :destroy
    delegate :material, to: :container
  end
end

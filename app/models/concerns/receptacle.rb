# frozen_string_literal: true

# Receptacle
module Receptacle
  extend ActiveSupport::Concern

  included do
    has_one :container, as: :material, dependent: :destroy
  end
end

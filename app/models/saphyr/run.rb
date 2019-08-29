# frozen_string_literal: true

# Saphyr namespace
module Saphyr
  # Saphyr::Run
  # A saphyr run can have a saphyr chip
  class Run < ApplicationRecord
    enum state: { pending: 0, started: 1, completed: 2, cancelled: 3 }

    has_one :chip, foreign_key: :saphyr_run_id,
                   inverse_of: :run, dependent: :nullify

    scope :active, -> { where(deactivated_at: nil) }

    def active?
      deactivated_at.nil?
    end

    def name
      super.presence || id
    end

    def cancel
      return true unless active?

      update(deactivated_at: DateTime.current)
    end
  end
end

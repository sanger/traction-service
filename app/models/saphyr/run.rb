# frozen_string_literal: true

# Saphyr namespace
module Saphyr
  # Run
  class Run < ApplicationRecord
    enum state: %i[pending started completed cancelled]

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

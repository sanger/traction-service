# frozen_string_literal: true

# Saphyr namespace
module Saphyr
  # Run
  class Run < ApplicationRecord

    has_one :chip, foreign_key: :saphyr_run_id, dependent: :nullify # inverse_of: :run
    enum state: %i[pending started completed cancelled]

    scope :active, -> { where(deactivated_at: nil) }

    def active?
      deactivated_at.nil?
    end

    def name
      super || id
    end

    def cancel
      return true unless active?

      update(deactivated_at: DateTime.current)
    end
  end
end

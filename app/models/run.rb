# frozen_string_literal: true

require 'event_message'

# Run
class Run < ApplicationRecord
  has_one :chip, dependent: :nullify
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

  def generate_event
    begin
      message = EventMessage.new(self)
      BrokerHandle.publish(message)
    rescue => e
      Rails.logger.error e
      Rails.logger.error e.backtrace
    end
  end
end

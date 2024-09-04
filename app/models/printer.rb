# frozen_string_literal: true

# A device that can print labels based on the labware type
class Printer < ApplicationRecord
  enum :labware_type, { tube: 0, plate96: 1, plate384: 2 }

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :labware_type, presence: true

  scope :active, -> { where(deactivated_at: nil) }
  scope :inactive, -> { where.not(deactivated_at: nil) }

  def active?
    deactivated_at.nil?
  end

  def deactivate!
    update!(deactivated_at: Time.current)
  end
end

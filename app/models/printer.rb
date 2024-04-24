# frozen_string_literal: true

# A device that can print labels based on the labware type
class Printer < ApplicationRecord
  enum labware_type: { tube: 0, plate96: 1, plate384: 2 }

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :labware_type, presence: true
  validates :active, allow_nil: true, inclusion: { in: [true, false] }

  after_initialize :set_defaults

  private

  def set_defaults
    self.active ||= true
  end
end

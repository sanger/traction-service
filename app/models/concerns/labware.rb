# frozen_string_literal: true

# Material
module Labware
  extend ActiveSupport::Concern

  # turn into constant as enum no longer works
  # allows for a different prefix for each labware type
  ID_PREFIXES = { plate: 1, tube: 2 }.freeze

  included do
    after_create :generate_barcode

    validates :barcode, uniqueness: { case_sensitive: false }
  end

  class_methods do
    def prefix
      ID_PREFIXES[to_s.downcase.to_sym]
    end
  end

  def generate_barcode
    return if barcode.present?

    update(barcode: "TRAC-#{self.class.prefix}-#{id}")
  end
end

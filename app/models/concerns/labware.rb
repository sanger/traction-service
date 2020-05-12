# frozen_string_literal: true

# Material
module Labware
  extend ActiveSupport::Concern

  included do
    enum id_prefix: { plate: 1, tube: 2 }
    after_create :generate_barcode

    validates :barcode, uniqueness: { case_sensitive: false }
  end

  class_methods do
    def prefix
      id_prefixes[to_s.downcase.to_sym]
    end
  end

  def generate_barcode
    return if barcode.present?

    update(barcode: "TRAC-#{self.class.prefix}-#{id}")
  end
end

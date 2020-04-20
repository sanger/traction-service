# frozen_string_literal: true

# Material
module Labware
  extend ActiveSupport::Concern

  included do
    enum id_prefix: { plate: 1, tube: 2 }
    after_create :generate_barcode
  end

  def generate_barcode
    # debugger
    return if barcode.present?

    update(barcode: "TRAC-#{self.class.id_prefixes[self.class.to_s.downcase.to_sym]}-#{id}")
  end
end

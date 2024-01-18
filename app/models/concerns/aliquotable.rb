# frozen_string_literal: true

# Aliquotable
module Aliquotable
  extend ActiveSupport::Concern

  included do
    has_many :aliquots, as: :source, dependent: :nullify
  end

  def primary_aliquot
    # Something fundamentally wrong if we have more than one
    aliquots.find_by(aliquot_type: :primary)
  end

  def derived_aliquots
    aliquots.where(aliquot_type: :derived)
  end
end

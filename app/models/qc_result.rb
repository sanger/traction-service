# frozen_string_literal: true

class QcResult < ApplicationRecord
  enum decision_made_by: { long_read: 0, tol: 1 }

  belongs_to :qc_assay_type

  validates :labware_barcode, :sample_external_id, :value, :decision_made_by, presence: true
end

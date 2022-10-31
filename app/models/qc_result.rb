# frozen_string_literal: true

class QcResult < ApplicationRecord
  enum status: { pass: 0, fail: 1, failed_profile: 2, on_hold_uli: 3, review: 4, na_control: 5 }
  enum decision_made_by: { long_read: 0, tol: 1 }

  belongs_to :qc_assay_type

  validates :labware_barcode, presence: true
  validates :sample_external_id, presence: true
  validates :value, presence: true
end

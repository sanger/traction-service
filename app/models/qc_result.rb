# frozen_string_literal: true

class QcResult < ApplicationRecord
  belongs_to :qc_assay_type

  validates :labware_barcode, presence: true
  validates :sample_external_id, presence: true
  validates :value, presence: true
end

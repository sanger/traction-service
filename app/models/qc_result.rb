# frozen_string_literal: true

class QcResult < ApplicationRecord
  belongs_to :qc_assay_type
  validates :labware_barcode, :sample_external_id, :value, presence: true
end

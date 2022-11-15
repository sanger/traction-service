# frozen_string_literal: true

class QcResult < ApplicationRecord
  belongs_to :qc_assay_type
  has_many :qc_decision_results
  validates :labware_barcode, :sample_external_id, :value, presence: true
end

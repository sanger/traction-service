# frozen_string_literal: true

class QcResult < ApplicationRecord
  belongs_to :qc_assay_type

  has_many :qc_decision_results, dependent: :restrict_with_error
  has_many :qc_decisions, through: :qc_decision_results

  validates :labware_barcode, :sample_external_id, :value, presence: true
end

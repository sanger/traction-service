# frozen_string_literal: true

class QcResult < ApplicationRecord
  belongs_to :qc_assay_type
  has_many :qc_results_decisions
  has_many :qc_decisions, :through => :qc_results_decisions
  validates :labware_barcode, :sample_external_id, :value, presence: true
end

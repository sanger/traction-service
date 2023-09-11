# frozen_string_literal: true

# A QC result is an individual piece of QC on a sample
# e.g. A femto result for sample in tube with barcode ...
# A sample can have many QC results
# Has an optional column qc_reception_id for storing the id associated with
# qc_results received through qc_reception endpoint
class QcResult < ApplicationRecord
  belongs_to :qc_assay_type
  belongs_to :qc_reception, optional: true

  has_many :qc_decision_results, dependent: :restrict_with_error
  has_many :qc_decisions, through: :qc_decision_results

  validates :labware_barcode, :sample_external_id, :value, presence: true
end

# frozen_string_literal: true

# A QC result can have multiple QC decisions
class QcDecisionResult < ApplicationRecord
  belongs_to :qc_decision
  belongs_to :qc_result
end

# frozen_string_literal: true

# A QC decision is a decision made by a person in the lab on the qc result.
# The group who made the decision is recorded
class QcDecision < ApplicationRecord
  enum :decision_made_by, { long_read: 0, tol: 1 }

  has_many :qc_decision_results, dependent: :restrict_with_error
  has_many :qc_results, through: :qc_decision_results

  validates :decision_made_by, :status, presence: true
end

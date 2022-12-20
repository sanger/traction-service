# frozen_string_literal: true

class QcDecision < ApplicationRecord
  enum decision_made_by: { long_read: 0, tol: 1 }

  has_many :qc_decision_results, dependent: :restrict_with_error
  has_many :qc_results, through: :qc_decision_results

  validates :decision_made_by, :status, presence: true
end

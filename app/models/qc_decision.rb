# frozen_string_literal: true

class QcDecision < ApplicationRecord
  enum decision_made_by: { long_read: 0, tol: 1 }
  
  has_many :qc_results_decisions
  has_many :qc_results, :through => :qc_results_decisions

  validates :decision_made_by, presence: true
end

# frozen_string_literal: true

class QcDecision < ApplicationRecord
  enum decision_made_by: { long_read: 0, tol: 1 }


  validates :decision_made_by, presence: true
end

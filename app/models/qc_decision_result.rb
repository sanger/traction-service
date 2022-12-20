# frozen_string_literal: true

class QcDecisionResult < ApplicationRecord
  belongs_to :qc_decision
  belongs_to :qc_result
end

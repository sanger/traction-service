# frozen_string_literal: true

# WorkflowStep
class WorkflowStep < ApplicationRecord
  belongs_to :workflow

  validates :code, presence: true, uniqueness: { case_sensitive: false }
end

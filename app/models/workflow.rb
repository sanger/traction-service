# frozen_string_literal: true

# Workflow
class Workflow < ApplicationRecord
  include WorkflowPipelineable
  has_many :workflow_steps, dependent: :destroy
  accepts_nested_attributes_for :workflow_steps, allow_destroy: true

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end

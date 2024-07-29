# frozen_string_literal: true

# Sample
class Sample < ApplicationRecord
  has_many :requests, dependent: :nullify

  attr_readonly :name

  enum retention_instruction: {
    destroy_after_2_years: 0,
    return_to_customer_after_2_years: 1,
    long_term_storage: 2
  }

  validates :species, presence: true
  validates :external_id, presence: true, uuid: true
  validates :name, uniqueness: { case_sensitive: false }, presence: true
  validates :retention_instruction, inclusion: { in: Sample.retention_instructions.keys },
                                    allow_nil: true, on: :create

  def active?
    deactivated_at.nil?
  end
end

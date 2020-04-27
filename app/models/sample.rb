# frozen_string_literal: true

# Sample
class Sample < ApplicationRecord
  has_many :requests, dependent: :nullify

  attr_readonly :name

  validates :name, :external_id, :species, presence: true
  validates :name, uniqueness: { case_sensitive: false }

  def active?
    deactivated_at.nil?
  end
end

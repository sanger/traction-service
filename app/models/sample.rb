# frozen_string_literal: true

# Sample
class Sample < ApplicationRecord
  has_many :requests, dependent: :nullify

  attr_readonly :name

  validates :name, :external_id, :species, presence: true
  validates :name, uniqueness: true

  def active?
    deactivated_at.nil?
  end
end

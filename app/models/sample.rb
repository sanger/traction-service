# frozen_string_literal: true

# Sample
class Sample < ApplicationRecord
  include Material

  validates :name, :external_id, :species, presence: true

  validates :name, :external_id, :species, presence: true
  validates :name, uniqueness: true

  has_many :requests, dependent: :nullify

  attr_readonly :name

  def active?
    deactivated_at.nil?
  end
end

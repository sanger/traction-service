# frozen_string_literal: true

# Sample
class Sample < ApplicationRecord
  has_many :requests, dependent: :nullify

  attr_readonly :name

  validates :species, presence: true
  validates :external_id, presence: true, uuid: true
  validates :name, uniqueness: { case_sensitive: false }, presence: true

  def active?
    deactivated_at.nil?
  end
end

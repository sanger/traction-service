# frozen_string_literal: true

# Sample
class Sample < ApplicationRecord
  include Material

  attr_readonly :name
  validates :name, :sequencescape_request_id, :species, presence: true
  validates :name, uniqueness: true
  has_many :libraries, dependent: :nullify

  def active?
    deactivated_at.nil?
  end
end

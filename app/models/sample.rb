# frozen_string_literal: true

# Sample
class Sample < ApplicationRecord
  include Material

  has_many :libraries, class_name: 'Saphyr::Library', inverse_of: :sample, dependent: :nullify

  validates :name, :external_id, :external_study_id, :species, presence: true
  validates :name, uniqueness: true

  attr_readonly :name

  def active?
    deactivated_at.nil?
  end
end

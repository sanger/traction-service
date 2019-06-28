# frozen_string_literal: true

# Enzyme
class Enzyme < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: true

  has_many :libraries, class_name: 'Saphyr::Library', inverse_of: :enzyme, dependent: :nullify
end

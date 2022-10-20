# frozen_string_literal: true

class QcAssayType < ApplicationRecord
  validates :key, presence: true
  validates :label, presence: true
end

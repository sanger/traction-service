# frozen_string_literal: true

class QcAssayType < ApplicationRecord
  enum used_by: { extraction: 0 }
  validates :key, presence: true
  validates :label, presence: true
end

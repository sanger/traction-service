# frozen_string_literal: true

class QcAssayType < ApplicationRecord
  enum used_by: { long_read: 0, tol: 1 }
  validates :key, presence: true
  validates :label, presence: true
end

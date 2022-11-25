# frozen_string_literal: true

class QcAssayType < ApplicationRecord
  enum used_by: { extraction: 0, some_future_group: 1 }
  validates :key, presence: true
  validates :label, presence: true
end

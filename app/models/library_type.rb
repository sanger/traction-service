# frozen_string_literal: true

# A library type sub-divides pipelines into different products, identifying the
# protocol that has been performed. They are exposed downstream, and can affect
# the analysis performed by NPG.
class LibraryType < ApplicationRecord
  enum pipeline: Pipelines::ENUMS, _suffix: true

  validates :pipeline, presence: true
  validates :name, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }
end

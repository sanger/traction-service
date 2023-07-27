# frozen_string_literal: true

# A QC Assay is a standard assay which is used to carry out QC e.g. Femto
class QcAssayType < ApplicationRecord
  enum used_by: { extraction: 0, tol: 1 }
  validates :key, presence: true
  validates :label, presence: true
end

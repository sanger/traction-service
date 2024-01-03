# frozen_string_literal: true

# Aliquot
# A portion of a sample that is used for a library, sample or pool
# An aliquot can be a primary aliquot or a derived aliquot
# An aliquot can be used to track volumes and concentrations of samples
class Aliquot < ApplicationRecord
  enum state: { created: 0, used: 1 }
  enum aliquot_type: { primary: 0, derived: 1 }

  belongs_to :tag, optional: true
  belongs_to :source, polymorphic: true

  validates :volume, :concentration, presence: true
end

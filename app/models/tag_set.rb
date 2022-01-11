# frozen_string_literal: true

# Represents a collection of tags, generally bought together as a product
# Also known as a barcode set
class TagSet < ApplicationRecord
  has_many :tags, dependent: :restrict_with_error

  enum pipeline: { pacbio: 0, ont: 1, saphyr: 2 }, _suffix: true
  enum sample_sheet_behaviour: { default: 0, hidden: 1 }, _suffix: true

  validates :name, presence: true
  validates :pipeline, presence: true

  def sample_sheet_behaviour_class
    SampleSheetBehaviour.get(sample_sheet_behaviour)
  end
end

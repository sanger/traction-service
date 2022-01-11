# frozen_string_literal: true

# Tag
class Tag < ApplicationRecord
  belongs_to :tag_set
  has_many :tag_taggables, dependent: :destroy

  delegate :name, :sample_sheet_behaviour_class, to: :tag_set, prefix: :tag_set, allow_nil: true
  delegate :barcode_name, :barcode_set, :barcoded_for_sample_sheet?, to: :behaviour

  validates :oligo, :group_id, :tag_set_id, presence: true

  validates :oligo, uniqueness: { scope: :tag_set_id,
                                  message: 'oligo should only appear once within set',
                                  case_sensitive: false }

  validates :group_id, uniqueness: { scope: :tag_set_id,
                                     message: 'group id should only appear once within set',
                                     case_sensitive: false }

  def self.includes_args
    :tag_set
  end

  def behaviour
    tag_set_sample_sheet_behaviour_class.new(self)
  end
end

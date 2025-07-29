# frozen_string_literal: true

# Tag
class Tag < ApplicationRecord
  belongs_to :tag_set
  has_many :tag_taggables, dependent: :destroy

  delegate :name, to: :tag_set, prefix: :tag_set, allow_nil: true

  validates :oligo, :group_id, presence: true

  validates :oligo, uniqueness: { scope: :tag_set_id,
                                  message: :duplicated_in_tag_set,
                                  case_sensitive: false }

  validates :group_id, uniqueness: { scope: :tag_set_id,
                                     message: :duplicated_in_tag_set,
                                     case_sensitive: false }

  def adapter_1
    "#{group_id}#{'_F' if oligo_reverse.present?}"
  end

  def adapter_2
    "#{group_id}#{'_R' if oligo_reverse.present?}"
  end

  def asymmetric?
    oligo_reverse.present?
  end
end

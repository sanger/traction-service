# frozen_string_literal: true

# Tag
class Tag < ApplicationRecord
  belongs_to :tag_set
  has_many :tag_taggables, dependent: :destroy

  delegate :name, to: :tag_set, prefix: :tag_set, allow_nil: true

  validates :oligo, :group_id, presence: true

  validates :oligo, uniqueness: { scope: :tag_set_id,
                                  message: I18n.t('errors.messages.uniqueness.oligo'),
                                  case_sensitive: false }

  validates :group_id, uniqueness: { scope: :tag_set_id,
                                     message: I18n.t('errors.messages.uniqueness.group_id'),
                                     case_sensitive: false }
end

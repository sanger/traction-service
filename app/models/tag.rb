# frozen_string_literal: true

# Tag
class Tag < ApplicationRecord
  belongs_to :tag_set

  delegate :name, to: :tag_set, prefix: :tag_set, allow_nil: true

  validates :oligo, :group_id, :tag_set_id, presence: true

  validates :oligo, uniqueness: { scope: :tag_set_id,
                                  message: 'oligo should only appear once within set' }

  validates :group_id, uniqueness: { scope: :tag_set_id,
                                     message: 'group id should only appear once within set' }
end

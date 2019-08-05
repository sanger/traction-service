# frozen_string_literal: true

# Tag
class Tag < ApplicationRecord
  validates :oligo, :group_id, :set_name, presence: true

  validates :oligo, uniqueness: { scope: :set_name,
                                  message: 'oligo should only appear once within set' }
end

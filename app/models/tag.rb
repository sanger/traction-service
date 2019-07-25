# frozen_string_literal: true

class Tag < ApplicationRecord
  validates :oligo, :group_id, :set_name, presence: true
end

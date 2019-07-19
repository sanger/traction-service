# frozen_string_literal: true

module Pacbio
  # Pacbio::Tag
  class Tag < ApplicationRecord
    validates :oligo, :group_id, presence: true
  end
end

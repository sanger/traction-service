# frozen_string_literal: true

module Pacbio
  # Pacbio::Tag
  class Tag < ApplicationRecord
    validates :oligo, presence: true
  end
end

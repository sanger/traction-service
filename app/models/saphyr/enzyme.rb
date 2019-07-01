# frozen_string_literal: true

# Saphyr namespace
module Saphyr
  # Enzyme
  class Enzyme < ApplicationRecord
    validates :name, presence: true
    validates :name, uniqueness: true

    has_many :libraries, class_name: 'Saphyr::Library',
                         foreign_key: 'saphyr_enzyme_id', inverse_of: :enzyme,
                         dependent: :nullify
  end
end

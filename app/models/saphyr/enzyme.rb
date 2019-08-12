# frozen_string_literal: true

# Saphyr namespace
module Saphyr
  # Saphyr::Enzyme
  # A saphyr enzyme can have many libraries
  # A saphyr library must belong to a saphyr enzyme
  class Enzyme < ApplicationRecord
    has_many :libraries, class_name: 'Saphyr::Library',
                         foreign_key: 'saphyr_enzyme_id', inverse_of: :enzyme,
                         dependent: :nullify

    validates :name, presence: true
    validates :name, uniqueness: true
  end
end

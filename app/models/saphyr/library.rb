# frozen_string_literal: true

# Saphyr namespace
module Saphyr
  # Library
  class Library < ApplicationRecord
    include Material

    before_create :set_state
    belongs_to :request, class_name: 'Saphyr::Request',
                         foreign_key: 'saphyr_request_id', inverse_of: false

    belongs_to :enzyme, class_name: 'Saphyr::Enzyme', foreign_key: 'saphyr_enzyme_id',
                        inverse_of: :libraries

    has_many :flowcells, class_name: 'Saphyr::Flowcell',
                         foreign_key: 'saphyr_library_id', inverse_of: :library,
                         dependent: :nullify

    scope :active, -> { where(deactivated_at: nil) }

    def active?
      deactivated_at.nil?
    end

    def set_state
      self.state = 'pending'
    end

    def deactivate
      return false unless active?

      update(deactivated_at: DateTime.current)
    end
  end
end

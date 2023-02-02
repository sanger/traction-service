# frozen_string_literal: true

module Ont
  # Ont::MinKnowVersion
  class MinKnowVersion < ApplicationRecord
    validates :name, presence: true, uniqueness: true, format: Version::FORMAT

    # This is the other side of the belongs_to association in ont runs.
    has_many :runs, class_name: 'Ont::Run', dependent: :destroy, inverse_of: :min_know_version

    scope :active, -> { where(active: true) }
    scope :ordered_by_default, -> { order(default: :desc) }

    # Returns the default SMRT Link version.
    def self.default
      find_by(default: true, active: true)
    end
  end
end

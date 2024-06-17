# frozen_string_literal: true

module Pacbio
  # Pacbio::SmrtLinkVersion
  class SmrtLinkVersion < ApplicationRecord
    validates :name, presence: true, uniqueness: true, format: Version::FORMAT

    has_many :smrt_link_option_versions, class_name: 'Pacbio::SmrtLinkOptionVersion',
                                         foreign_key: :pacbio_smrt_link_version_id,
                                         dependent: :destroy, inverse_of: :smrt_link_version
    has_many :smrt_link_options, through: :smrt_link_option_versions, source: :smrt_link_option,
                                 class_name: 'Pacbio::SmrtLinkOption'

    # This is the other side of the belongs_to association in pacbio runs.
    has_many :runs, class_name: 'Pacbio::Run', dependent: :destroy, inverse_of: :smrt_link_version

    scope :active, -> { where(active: true) }
    scope :ordered_by_default, -> { order(default: :desc) }

    # @return [Hash] default options for this version
    # each key is the option key and the value is the default value
    # if the default value is nil then it is not included
    def default_options
      {}.tap do |options|
        smrt_link_options.where.not(default_value: nil).find_each do |option|
          options[option.key] = option.default_value
        end
      end
    end

    # Returns the default SMRT Link version.
    def self.default
      find_by(default: true,
              active: true) || raise('There is no default SMRT Link Version.
              Please create one or Traction will implode.')
    end
  end
end

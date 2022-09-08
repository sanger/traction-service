# frozen_string_literal: true

module Pacbio
  # Pacbio::SmrtLinkVersion
  class SmrtLinkVersion < ApplicationRecord
    validates :name, presence: true, uniqueness: true, format: Version::FORMAT

    has_many :smrt_link_option_versions, class_name: 'Pacbio::SmrtLinkOptionVersion',
                                         foreign_key: :pacbio_smrt_link_option_id,
                                         dependent: :destroy, inverse_of: :smrt_link_version
    has_many :smrt_link_options, through: :smrt_link_option_versions, source: :smrt_link_option,
                                 class_name: 'Pacbio::SmrtLinkOption'
  end
end

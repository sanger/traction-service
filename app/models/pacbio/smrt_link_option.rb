# frozen_string_literal: true

module Pacbio
  # Pacbio::SmrtLinkOption
  class SmrtLinkOption < ApplicationRecord
    has_many :smrt_link_option_versions, class_name: 'Pacbio::SmrtLinkOptionVersion',
                                         foreign_key: :pacbio_smrt_link_option_id, autosave: true
    has_many :smrt_link_versions, through: :smrt_link_option_versions, source: :smrt_link_version,
                                  class_name: 'Pacbio::SmrtLinkVersion'

    validates :key, presence: true
    validates :label, presence: true
  end
end

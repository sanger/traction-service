# frozen_string_literal: true

module Pacbio
  # Pacbio::SmrtLinkVersion
  class SmrtLinkOptionVersion < ApplicationRecord
    belongs_to :smrt_link_option, class_name: 'Pacbio::SmrtLinkOption',
                                  foreign_key: :pacbio_smrt_link_option_id,
                                  inverse_of: :smrt_link_option_versions
    belongs_to :smrt_link_version, class_name: 'Pacbio::SmrtLinkVersion',
                                   foreign_key: :pacbio_smrt_link_version_id,
                                   inverse_of: :smrt_link_option_versions
  end
end

# frozen_string_literal: true

module Pacbio
  # Pacbio::SmrtLinkOption
  class SmrtLinkOption < ApplicationRecord
    enum :data_type, { string: 0, number: 1, list: 2 }

    has_many :smrt_link_option_versions, class_name: 'Pacbio::SmrtLinkOptionVersion',
                                         foreign_key: :pacbio_smrt_link_option_id,
                                         dependent: :destroy, inverse_of: :smrt_link_option
    has_many :smrt_link_versions, through: :smrt_link_option_versions, source: :smrt_link_version,
                                  class_name: 'Pacbio::SmrtLinkVersion'

    validates :key, presence: true, uniqueness: true
    validates :label, presence: true

    # we only need select_options if the data type is a list
    validates :select_options, presence: true, if: :list?
  end
end

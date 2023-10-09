# frozen_string_literal: true

module V1
  module Pacbio
    # SmrtLinkVersionResource - Return the SMRT Link Versions
    class SmrtLinkVersionResource < JSONAPI::Resource
      model_name 'Pacbio::SmrtLinkVersion'

      attributes :name, :default, :active

      has_many :smrt_link_option_versions, class_name: 'SmrtLinkOptionVersion'
    end
  end
end

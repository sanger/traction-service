# frozen_string_literal: true

module V1
  module Pacbio
    # SmrtLinkVersionResource - Return the SMRT Link Versions
    class SmrtLinkVersionResource < JSONAPI::Resource
      model_name 'Pacbio::SmrtLinkVersion'

      attributes :name, :default

      has_many :smrt_link_option_versions, class_name: 'SmrtLinkOptionVersion'

      # Returns active versions.
      def self.records(_options = {})
        super.active
      end
    end
  end
end

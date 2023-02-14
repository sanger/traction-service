# frozen_string_literal: true

module V1
  module Pacbio
    # Class SmrtLinkOptionVersionResource
    class SmrtLinkOptionVersionResource < JSONAPI::Resource
      model_name 'Pacbio::SmrtLinkOptionVersion'

      has_one :smrt_link_option
      has_one :smrt_link_version
    end
  end
end

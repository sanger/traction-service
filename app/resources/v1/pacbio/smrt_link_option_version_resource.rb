# frozen_string_literal: true

module V1
  module Pacbio
    # SmrtLinkOptionVersionResource - each SMRT link version can have multiple options
    # Each SMRT Linke Option can belong to multiple versions
    class SmrtLinkOptionVersionResource < JSONAPI::Resource
      model_name 'Pacbio::SmrtLinkOptionVersion'

      has_one :smrt_link_option
      has_one :smrt_link_version
    end
  end
end

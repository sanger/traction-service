# frozen_string_literal: true

module V1
  module Pacbio
    # SmrtLinkOptionResource - a resource to return the SMRT link options for a particular
    # SMRT Link version
    class SmrtLinkOptionResource < JSONAPI::Resource
      model_name 'Pacbio::SmrtLinkOption'

      attributes :key, :label, :default_value, :data_type, :select_options
    end
  end
end

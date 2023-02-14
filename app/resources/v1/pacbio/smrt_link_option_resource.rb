# frozen_string_literal: true

module V1
  module Pacbio
    # class SmrtLinkOptionResource
    class SmrtLinkOptionResource < JSONAPI::Resource
      model_name 'Pacbio::SmrtLinkOption'

      attributes :key, :label, :default_value, :data_type, :select_options
    end
  end
end

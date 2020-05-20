# frozen_string_literal: true

module Pipelines
  # An accessor for environment constants
  class ConstantsAccessor
    def self.pcr_tag_set_name
      Rails.configuration.env_constants[:ont][:covid][:pcr_tag_set][:name]
    end

    def self.pcr_tag_set_hostname
      Rails.configuration.env_constants[:ont][:covid][:pcr_tag_set][:hostname]
    end

    def self.ont_covid_study_uuid
      Rails.configuration.env_constants[:ont][:covid][:study_uuid]
    end
  end
end

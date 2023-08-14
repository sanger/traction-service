# frozen_string_literal: true

module V1
  # SampleResource
  class SampleResource < JSONAPI::Resource
    attributes :name, :external_id, :species, :created_at, :deactivated_at
    attributes :sanger_sample_id, :supplier_name, :taxon_id, :donor_id, :country_of_origin,
               :accession_number

    def created_at
      @model.created_at.to_fs(:us)
    end

    def deactivated_at
      @model&.deactivated_at&.to_fs(:us)
    end
  end
end

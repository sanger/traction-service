# frozen_string_literal: true

module V1
  # `SampleResource` provides a **JSON:API** representation of the `Sample` model.
  # It allows API clients to query, filter, and retrieve sample-related information.
  #
  # @note Access this resource via the `/v1/samples` endpoint.
  #
  # Provides a JSON:API representation of {Sample} and exposes valid request
  # for use by the UI.
  #
  # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
  # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package for the service
  # implementation of the JSON:API standard.
  class SampleResource < JSONAPI::Resource
    # @!attribute [rw] name
    #   @return [String] the name of the sample
    # @!attribute [rw] external_id
    #   @return [String] the external ID of the sample
    # @!attribute [rw] species
    #   @return [String] the species of the sample
    # @!attribute [rw] created_at
    #   @return [String] the creation date of the sample in US format
    # @!attribute [rw] deactivated_at
    #   @return [String, nil] the deactivation date of the sample in US format;
    #     nil if not deactivated
    # @!attribute [rw] sanger_sample_id
    #   @return [String] the Sanger sample ID
    # @!attribute [rw] supplier_name
    #   @return [String] the name of the supplier
    # @!attribute [rw] taxon_id
    #   @return [String] the taxon ID
    # @!attribute [rw] donor_id
    #   @return [String] the donor ID
    # @!attribute [rw] country_of_origin
    #   @return [String] the country of origin
    # @!attribute [rw] accession_number
    #   @return [String] the accession number
    # @!attribute [rw] date_of_sample_collection
    #   @return [String] the date of sample collection
    attributes :name, :external_id, :species, :created_at, :deactivated_at
    attributes :sanger_sample_id, :supplier_name, :taxon_id, :donor_id, :country_of_origin,
               :accession_number, :date_of_sample_collection

    def created_at
      @model.created_at.to_fs(:us)
    end

    def deactivated_at
      @model&.deactivated_at&.to_fs(:us)
    end
  end
end

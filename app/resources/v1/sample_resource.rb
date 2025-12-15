# frozen_string_literal: true

module V1
  # It allows API clients to query, filter, and retrieve sample-related information.
  #
  # @note Access this resource cannot be accessed via the `/v1/samples` endpoint.
  # It is only accessible via the nested route under other resources using includes.
  #
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
    # @!attribute [rw] number_of_donors
    #  @return [Integer] the number of donors associated with the sample
    attributes :name, :external_id, :species, :created_at, :deactivated_at,
               :sanger_sample_id, :supplier_name, :taxon_id, :donor_id, :country_of_origin,
               :accession_number, :date_of_sample_collection, :number_of_donors

    def created_at
      @model.created_at.to_fs(:us)
    end

    def deactivated_at
      @model&.deactivated_at&.to_fs(:us)
    end
  end
end

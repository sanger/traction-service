# frozen_string_literal: true

# JSON-API resources wont resolve across namespaces spaces
# so we need the Aliquot resource in the PacBio namespace
module V1
  # @todo This documentation does not yet include a detailed description of what this resource represents.
  # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
  # @todo This documentation does not yet include any example usage of the API via cURL or similar.
  #
  # @note Access this resource via the `/v1/aliquot/` endpoint.
  #
  # Provides a JSON:API representation of {Aliquot}.
  #
  # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
  # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
  # for the service implementation of the JSON:API standard.
  class AliquotResource < JSONAPI::Resource
    model_name 'Aliquot'

    # @!attribute [rw] aliquot_type
    #   @return [String] the type of the aliquot
    # @!attribute [rw] source_id
    #   @return [Integer] the ID of the source
    # @!attribute [rw] source_type
    #   @return [String] the type of the source
    # @!attribute [rw] used_by_id
    #   @return [Integer] the ID of the entity that used the aliquot
    # @!attribute [rw] used_by_type
    #   @return [String] the type of the entity that used the aliquot
    # @!attribute [rw] state
    #   @return [String] the state of the aliquot
    # @!attribute [rw] volume
    #   @return [Float] the volume of the aliquot
    # @!attribute [rw] concentration
    #   @return [Float] the concentration of the aliquot
    # @!attribute [rw] insert_size
    #   @return [Integer] the insert size of the aliquot
    # @!attribute [rw] template_prep_kit_box_barcode
    #   @return [String] the barcode of the template prep kit box
    # @!attribute [rw] tag_id
    #   @return [Integer] the ID of the tag associated with the aliquot
    attributes :aliquot_type, :source_id, :source_type, :used_by_id, :used_by_type, :state,
               :volume, :concentration, :insert_size, :template_prep_kit_box_barcode, :tag_id

    has_one :tag, always_include_optional_linkage_data: true
  end
end

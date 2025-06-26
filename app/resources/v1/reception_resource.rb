# frozen_string_literal: true

module V1
  # @todo This documentation does not yet include a detailed description of what this resource represents.
  # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
  # @todo This documentation does not yet include any example usage of the API via cURL or similar.
  #
  # @note Access this resource via the `/v1/receptions` endpoint.
  #
  # Provides a JSON:API representation of {Reception} and handles the import of resources into
  # traction
  #
  # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
  # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package for the service
  # implementation of the JSON:API standard.
  class ReceptionResource < JSONAPI::Resource
    # @!attribute [rw] source
    #   @return [String] the source of the reception
    # @!attribute [rw] labware
    #   @return [Array<Hash>] the labware associated with the reception
    # @!attribute [rw] plates_attributes
    #   @return [Array<Hash>] the attributes of the plates
    # @!attribute [rw] tubes_attributes
    #   @return [Array<Hash>] the attributes of the tubes
    # @!attribute [rw] pool_attributes
    #   @return [Hash] the attributes of the pool
    attributes :source, :labware, :plates_attributes, :tubes_attributes, :pool_attributes,
               :compound_sample_tubes_attributes

    after_create :publish_messages, :construct_resources!

    def fetchable_fields
      %i[source labware]
    end

    def self.creatable_fields(context)
      super - [:labware]
    end

    def labware
      context[:labware] || []
    end

    private

    def plates_attributes=(plate_parameters)
      raise ArgumentError unless plate_parameters.is_a?(Array)

      @model.plates_attributes = plate_parameters.map do |plate|
        plate.permit(
          :barcode,
          wells_attributes: [
            :position,
            { request: permitted_request_attributes,
              sample: permitted_sample_attributes }
          ]
        ).to_h.with_indifferent_access
      end
    end

    def tubes_attributes=(tube_parameters)
      raise ArgumentError unless tube_parameters.is_a?(Array)

      @model.tubes_attributes = tube_parameters.map do |tube|
        tube.permit(
          :barcode,
          library: permitted_library_attributes,
          request: permitted_request_attributes,
          sample: permitted_sample_attributes
        ).to_h.with_indifferent_access
      end
    end

    # method to handle incoming compound tube parameters
    def compound_sample_tubes_attributes=(compound_tube_parameters)
      raise ArgumentError unless compound_tube_parameters.is_a?(Array)

      # call model method to set compound tubes attributes
      @model.compound_sample_tubes_attributes = compound_tube_parameters.map do |tube|
        tube.permit(
          :barcode,
          library: permitted_library_attributes,
          request: permitted_request_attributes,
          samples: permitted_sample_attributes
        ).to_h.with_indifferent_access
      end
    end

    def pool_attributes=(pool_parameters)
      raise ArgumentError unless pool_parameters.is_a?(Object)

      @model.pool_attributes = pool_parameters.permit(
        *permitted_pool_attributes
      ).to_h.with_indifferent_access
    end

    def construct_resources!
      # Use context to cache the labware to be used in the response
      context[:labware] = @model.construct_resources!
    end

    def permitted_pool_attributes
      [*::Ont.pool_attributes, :barcode]
    end

    def permitted_library_attributes
      [*::Pacbio.library_attributes, *::Ont.library_attributes, :tag_sequence].uniq
    end

    def permitted_request_attributes
      [*::Pacbio.request_attributes, *::Ont.request_attributes].uniq
    end

    def permitted_sample_attributes
      %i[name external_id species study_uuid priority_level public_name
         sanger_sample_id supplier_name taxon_id donor_id country_of_origin
         accession_number date_of_sample_collection retention_instruction]
    end

    def publish_messages
      # Publish message for the sample table
      publish_message(
        @model.requests.map(&:sample),
        Pipelines.reception.sample.message
      )
      # Publish message for the stock_resource table
      publish_message(
        @model.requests,
        Pipelines.reception.stock_resource.message
      )
    end

    def publish_message(message, config)
      Messages.publish(message, config)
    end
  end
end

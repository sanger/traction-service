# frozen_string_literal: true

module V1
  module Saphyr
    # @todo This documentation does not yet include a detailed description of what this resource represents.
    # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
    # @todo This documentation does not yet include any example usage of the API via cURL or similar.
    #
    # @note Access this resource via the `/api/v1/saphyr/container_material/` endpoint.
    #
    # Provides a JSON:API representation of {ContainerMaterial}.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    class ContainerMaterialResource < JSONAPI::Resource
      model_name 'ContainerMaterial'

      # Library attributes
      # # @!attribute [rw] state
      # #   @return [String] the state of the container material
      # # @!attribute [rw] enzyme_name
      # #   @return [String] the name of the enzyme
      # # @!attribute [rw] deactivated_at
      # #   @return [String] the deactivation timestamp of the container material
      attributes :state, :enzyme_name, :deactivated_at

      # Request attributes
      # # @!attribute [rw] external_study_id
      # #   @return [String] the external study ID
      # # @!attribute [rw] sample_species
      # #   @return [String] the species of the sample
      attributes :external_study_id, :sample_species

      # Shared attributes
      # # @!attribute [rw] barcode
      # #   @return [String] the barcode of the container material
      # # @!attribute [rw] created_at
      # #   @return [String] the creation timestamp of the container material
      # # @!attribute [rw] sample_name
      # #   @return [String] the name of the sample
      # # @!attribute [rw] material_type
      # #   @return [String] the type of the material
      # # @!attribute [rw] material_id
      # #   @return [Integer] the ID of the material
      attributes :barcode, :created_at, :sample_name, :material_type, :material_id

      def fetchable_fields
        case @model.material
        when ::Saphyr::Library
          %i[state barcode created_at enzyme_name deactivated_at sample_name
             material_type material_id]
        when ::Saphyr::Request
          %i[external_study_id sample_name barcode sample_species created_at
             material_type material_id]
        else
          super
        end
      end

      def material_type
        @model.material_type.demodulize.downcase
      end

      def material_id
        @model.material.id
      end

      # Delegations to Container
      def barcode
        @model.container.barcode
      end

      # Delegations to Material
      def external_study_id
        @model.material.external_study_id
      end

      def sample_name
        case @model.material
        when ::Saphyr::Library
          @model.material.request.sample_name
        when ::Saphyr::Request
          @model.material.sample_name
        end
      end

      def sample_species
        @model.material.sample_species
      end

      def created_at
        @model.material.created_at.strftime('%Y/%m/%d %H:%M')
      end

      def state
        @model.material.state
      end

      def enzyme_name
        @model.material.enzyme.name
      end

      def deactivated_at
        return nil if @model.material.deactivated_at.nil?

        @model.material.deactivated_at.strftime('%Y/%m/%d %H:%M')
      end
    end
  end
end

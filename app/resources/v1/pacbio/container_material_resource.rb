# frozen_string_literal: true

module V1
  module Pacbio
    # @todo This documentation does not yet include a detailed description of what this resource represents.
    # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
    # @todo This documentation does not yet include any example usage of the API via cURL or similar.
    #
    # @note Access this resource via the `/api/v1/pacbio/container_material/` endpoint.
    #
    # Provides a JSON:API representation of {ContainerMaterial}.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    class ContainerMaterialResource < JSONAPI::Resource
      model_name 'ContainerMaterial'

      # Library attributes
      # @!attribute [rw] state
      #   @return [String] the state of the library
      # @!attribute [rw] insert_size
      #   @return [Integer] the insert size of the library
      # @!attribute [rw] volume
      #   @return [Float] the volume of the library
      # @!attribute [rw] concentration
      #   @return [Float] the concentration of the library
      # @!attribute [rw] template_prep_kit_box_barcode
      #   @return [String] the barcode of the template prep kit box
      # @!attribute [rw] deactivated_at
      #   @return [DateTime, nil] the deactivation time of the library, or nil if not deactivated
      # @!attribute [rw] sample_names
      #   @return [Array<String>] the names of the samples in the library
      attributes :state, :insert_size, :volume, :concentration,
                 :template_prep_kit_box_barcode, :deactivated_at, :sample_names

      # Request attributes
      # @!attribute [rw] library_type
      #   @return [String] the type of the library
      # @!attribute [rw] estimate_of_gb_required
      #   @return [Float] the estimated gigabytes required for the library
      # @!attribute [rw] number_of_smrt_cells
      #   @return [Integer] the number of SMRT cells required for the library
      # @!attribute [rw] cost_code
      #   @return [String] the cost code for the library
      # @!attribute [rw] external_study_id
      #   @return [String] the external study ID for the library
      # @!attribute [rw] sample_name
      #   @return [String] the name of the sample in the library
      # @!attribute [rw] sample_species
      #   @return [String] the species of the sample in the library
      attributes :library_type, :estimate_of_gb_required, :number_of_smrt_cells, :cost_code,
                 :external_study_id, :sample_name, :sample_species

      # Shared attributes
      # @!attribute [rw] barcode
      #   @return [String] the barcode of the container
      # @!attribute [rw] created_at
      #   @return [DateTime] the creation time of the container
      # @!attribute [rw] material_type
      #   @return [String] the type of material in the container
      attributes :barcode, :created_at, :material_type

      def fetchable_fields
        case @model.material
        when ::Pacbio::Library
          %i[state barcode volume concentration template_prep_kit_box_barcode insert_size
             created_at deactivated_at sample_names material_type]
        when ::Pacbio::Request
          %i[library_type estimate_of_gb_required number_of_smrt_cells cost_code external_study_id
             sample_name barcode sample_species created_at material_type]
        else
          super
        end
      end

      def self.records_for_populate(*_args)
        super.preload(:container, material: %i[material_type sample])
      end

      def material_type
        @model.material_type.demodulize.downcase
      end

      delegate :container, :material, to: :@model

      # Delegations to container
      def barcode
        @model.container.try(:barcode)
      end

      # Delegations to material
      delegate :library_type, :estimate_of_gb_required, :number_of_smrt_cells,
               :cost_code, :external_study_id,
               :sample_name, :sample_species, :state, :volume,
               :concentration, :template_prep_kit_box_barcode,
               :insert_size, :sample_names, to: :material

      # TODO: Moved here as dropped it from library, but this should probably become sample name.
      #      But overall, not really convinced this model should be exposed via the API.
      def sample_names
        material.sample.name
      end

      def created_at
        @model.material.created_at.strftime('%Y/%m/%d %H:%M')
      end

      def deactivated_at
        return nil if @model.material.deactivated_at.nil?

        @model.material.deactivated_at.strftime('%Y/%m/%d %H:%M')
      end
    end
  end
end

# frozen_string_literal: true

module V1
  module Pacbio
    # ContainerMaterialResource
    # TODO: probably via code review
    # I think this needs to be split based on whether the material is a request or a library
    # It also needs to be split on whether the container is a tube or well
    class ContainerMaterialResource < JSONAPI::Resource
      model_name 'ContainerMaterial'

      # Library attributes
      attributes :state, :fragment_size, :volume, :concentration,
                 :template_prep_kit_box_barcode, :deactivated_at, :sample_names

      # Request attributes
      attributes :library_type, :estimate_of_gb_required, :number_of_smrt_cells, :cost_code,
                 :external_study_id, :sample_name, :sample_species, :qc_status

      # Shared attributes
      attributes :barcode, :created_at, :material_type

      def fetchable_fields
        case @model.material
        when ::Pacbio::Library
          %i[state barcode volume concentration template_prep_kit_box_barcode fragment_size
             created_at deactivated_at sample_names material_type]
        when ::Pacbio::Request
          %i[library_type estimate_of_gb_required number_of_smrt_cells cost_code external_study_id
             sample_name barcode sample_species created_at material_type qc_status]
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
               :fragment_size, :sample_names, :qc_status, to: :material

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

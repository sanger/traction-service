# frozen_string_literal: true

module V1
  module Pacbio
    # ContainerMaterialResource
    class ContainerMaterialResource < JSONAPI::Resource
      model_name 'ContainerMaterial'

      # Library attributes
      attributes :state, :fragment_size, :volume, :concentration, :library_kit_barcode,
                 :deactivated_at, :sample_names

      # Request attributes
      attributes :library_type, :estimate_of_gb_required, :number_of_smrt_cells, :cost_code,
                 :external_study_id, :source_barcode, :sample_name, :sample_species

      # Shared attributes
      attributes :barcode, :created_at

      def fetchable_fields
        if @model.material.is_a?(::Pacbio::Library)
          %i[state barcode volume concentration library_kit_barcode fragment_size created_at
             deactivated_at sample_names]
        elsif @model.material.is_a?(::Pacbio::Request)
          %i[library_type estimate_of_gb_required number_of_smrt_cells cost_code external_study_id
             source_barcode sample_name barcode sample_species created_at]
        else
          super
        end
      end

      # Delegations to Container
      def barcode
        @model.container.barcode
      end

      # Delegations to Material
      def library_type
        @model.material.library_type
      end

      def estimate_of_gb_required
        @model.material.estimate_of_gb_required
      end

      def number_of_smrt_cells
        @model.material.number_of_smrt_cells
      end

      def cost_code
        @model.material.cost_code
      end

      def external_study_id
        @model.material.external_study_id
      end

      def source_barcode
        @model.material.source_barcode
      end

      def sample_name
        @model.material.sample_name
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

      def volume
        @model.material.volume
      end

      def concentration
        @model.material.concentration
      end

      def library_kit_barcode
        @model.material.library_kit_barcode
      end

      def fragment_size
        @model.material.fragment_size
      end

      def deactivated_at
        return nil if @model.material.deactivated_at.nil?

        @model.material.deactivated_at.strftime('%Y/%m/%d %H:%M')
      end

      def sample_names
        @model.material.sample_names
      end
    end
  end
end

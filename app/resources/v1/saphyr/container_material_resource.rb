# frozen_string_literal: true

module V1
  module Saphyr
    # ContainerMaterialResource
    class ContainerMaterialResource < JSONAPI::Resource
      model_name 'ContainerMaterial'

      # Library attributes
      attributes :state, :enzyme_name, :deactivated_at

      # Request attributes
      attributes :external_study_id, :sample_species

      # Shared attributes
      attributes :barcode, :created_at, :sample_name

      def fetchable_fields
        if @model.material.is_a?(::Saphyr::Library)
          %i[state barcode created_at enzyme_name deactivated_at sample_name]
        elsif @model.material.is_a?(::Saphyr::Request)
          %i[external_study_id
             sample_name barcode sample_species created_at]
        else
          super
        end
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
        if @model.material.is_a?(::Saphyr::Library)
          @model.material.request.sample_name
        elsif @model.material.is_a?(::Saphyr::Request)
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

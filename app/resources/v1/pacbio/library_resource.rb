# frozen_string_literal: true

require './app/resources/v1/shared/run_suitability'

module V1
  module Pacbio
    # LibraryResource
    class LibraryResource < JSONAPI::Resource
      include RunSuitability

      model_name 'Pacbio::Library'

      attributes :state, :volume, :concentration, :template_prep_kit_box_barcode,
                 :insert_size, :created_at, :deactivated_at, :source_identifier

      has_one :request, always_include_optional_linkage_data: true
      # If we don't specify the relation_name here, jsonapi-resources
      # attempts to use_related_resource_records_for_joins
      # In this case I can see it using container_associations
      # so seems to be linking the wrong tube relationship.
      has_one :tube, relation_name: :tube
      has_one :tag, always_include_optional_linkage_data: true
      has_one :pool, always_include_optional_linkage_data: true
      has_one :source_well, relation_name: :source_well, class_name: 'Well'
      has_one :source_plate, relation_name: :source_plate, class_name: 'Plate'

      def self.records_for_populate(*_args)
        super.preload(source_well: :plate, request: :sample,
                      tag: :tag_set,
                      container_material: { container: :barcode })
      end

      def created_at
        @model.created_at.to_fs(:us)
      end

      def deactivated_at
        @model&.deactivated_at&.to_fs(:us)
      end
    end
  end
end

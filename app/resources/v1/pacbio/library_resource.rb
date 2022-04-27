# frozen_string_literal: true

module V1
  module Pacbio
    # LibraryResource
    class LibraryResource < JSONAPI::Resource
      model_name 'Pacbio::Library'

      attributes :state, :volume, :concentration, :template_prep_kit_box_barcode,
                 :insert_size, :created_at, :deactivated_at, :source_identifier

      has_one :request, always_include_optional_linkage_data: true
      has_one :tube
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

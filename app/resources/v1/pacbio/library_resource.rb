# frozen_string_literal: true

module V1
  module Pacbio
    # LibraryResource
    class LibraryResource < JSONAPI::Resource
      model_name 'Pacbio::Library'

      attributes :state, :volume, :concentration, :template_prep_kit_box_barcode,
                 :fragment_size, :created_at, :deactivated_at, :source_identifier

      has_one :request
      has_one :tube
      has_one :tag

      def self.records_for_populate(*_args)
        super.preload(source_well: :plate, request: :sample,
                      tag: :tag_set,
                      container_material: { container: :barcode })
      end

      def created_at
        @model.created_at.to_s(:us)
      end

      def deactivated_at
        @model&.deactivated_at&.to_s(:us)
      end

    end
  end
end

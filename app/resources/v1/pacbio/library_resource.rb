# frozen_string_literal: true

module V1
  module Pacbio
    # LibraryResource
    class LibraryResource < JSONAPI::Resource
      include Shared::RunSuitability

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

      paginator :paged

      def self.default_sort
        [{ field: 'created_at', direction: :desc }]
      end

      # Something like this would be nice to have but it is tricky to implement because we
      # are dealing with records not instances
      #
      # filter :source_identifier, apply: lambda { |records, value, _options|
      #   records.select {|lib| lib.source_identifier == value}
      # }

      filter :pool
      filter :sample_name, apply: lambda { |records, value, _options|
        # We have to join requests and samples here in order to find by sample name
        records.joins(:request).joins(:sample).where(sample: { name: value })
      }
      filter :barcode, apply: lambda { |records, value, _options|
        records.joins(:tube).where(tube: { barcode: value })
      }
      filter :source_identifier, apply: lambda { |records, value, _options|
        # First we check tubes to see if there are any given the source identifier
        recs = records.joins(:source_tube).where(source_tube: { barcode: value })
        return recs unless recs.empty?

        # If no tubes match the source identifier we check plates
        return records.joins(:source_plate).where(source_plate: { barcode: value })
      }

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

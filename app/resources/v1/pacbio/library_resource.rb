# frozen_string_literal: true

module V1
  module Pacbio
    # LibraryResource
    class LibraryResource < JSONAPI::Resource
      include Shared::RunSuitability

      model_name 'Pacbio::Library'

      attributes :state, :volume, :concentration, :template_prep_kit_box_barcode,
                 :insert_size, :created_at, :deactivated_at, :source_identifier,
                 :pacbio_request_id, :tag_id, :primary_aliquot_attributes,
                 :used_volume, :available_volume

      has_one :request, always_include_optional_linkage_data: true
      # If we don't specify the relation_name here, jsonapi-resources
      # attempts to use_related_resource_records_for_joins
      # In this case I can see it using container_associations
      # so seems to be linking the wrong tube relationship.
      has_one :tag, always_include_optional_linkage_data: true
      has_one :tube, relation_name: :tube, always_include_optional_linkage_data: true
      has_one :source_well, relation_name: :source_well, class_name: 'Well'
      has_one :source_plate, relation_name: :source_plate, class_name: 'Plate'

      has_one :primary_aliquot, always_include_optional_linkage_data: true,
                                relation_name: :primary_aliquot, class_name: 'Aliquot'
      has_many :used_aliquots, always_include_optional_linkage_data: true,
                               relation_name: :used_aliquots, class_name: 'Aliquot'

      paginator :paged

      def self.default_sort
        [{ field: 'created_at', direction: :desc }]
      end

      # When a library is updated and it is attached to a run we need
      # to republish the messages for the run
      after_update :publish_messages

      after_create :push_volume_tracking_message

      filter :sample_name, apply: lambda { |records, value, _options|
        # We have to join requests and samples here in order to find by sample name
        records.joins(:sample).where(sample: { name: value })
      }
      filter :barcode, apply: lambda { |records, value, _options|
        # If wildcard is the last value passed we want to do a wildcard search
        if value.last == 'wildcard'
          return records.joins(:tube).where('tubes.barcode LIKE ?', "%#{value[0]}%")
        end

        records.joins(:tube).where(tubes: { barcode: value })
      }
      filter :source_identifier, apply: lambda { |records, value, _options|
        # First we check tubes to see if there are any given the source identifier
        recs = records.joins(:source_tube).where(source_tube: { barcode: value })
        return recs unless recs.empty?

        # If no tubes match the source identifier we check plates
        # If source identifier specifies a well we need to match samples to well
        # TODO: The below value[0] means we only take the first value passed in the filter
        #       If we want to support multiple values in one filter we would need to update this
        plate, well = value[0].split(':')
        recs = records.joins(:source_plate).where(source_plate: { barcode: plate })
        well ? recs.joins(:source_well).where(source_well: { position: well }) : recs
      }

      def self.records_for_populate(*_args)
        super.preload(source_well: :plate, request: :sample,
                      tag: :tag_set,
                      container_material: { container: :barcode })
      end

      def primary_aliquot_attributes=(primary_aliquot_parameters)
        @model.primary_aliquot_attributes = primary_aliquot_parameters.permit(
          :id, :volume, :template_prep_kit_box_barcode,
          :concentration, :insert_size, :tag_id
        )
      end

      def fetchable_fields
        super - [:primary_aliquot_attributes]
      end

      def created_at
        @model.created_at.to_fs(:us)
      end

      def deactivated_at
        @model&.deactivated_at&.to_fs(:us)
      end

      def publish_messages
        Messages.publish(@model.sequencing_runs, Pipelines.pacbio.message)
        push_volume_tracking_message
      end

      def push_volume_tracking_message
        Emq::Publisher.publish(@model.primary_aliquot, Pipelines.pacbio, 'volume_tracking')
      end
    end
  end
end

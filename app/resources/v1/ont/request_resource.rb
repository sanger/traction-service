# frozen_string_literal: true

module V1
  module Ont
    # RequestResource
    class RequestResource < JSONAPI::Resource
      model_name 'Ont::Request', add_model_hint: false

      attributes(*::Ont.request_attributes, :sample_name, :source_identifier, :created_at)

      paginator :paged

      filter :sample_name, apply: lambda { |records, value, _options|
        # We have to join requests and samples here in order to find by sample name
        records.joins(:sample).where(sample: { name: value })
      }

      filter :source_identifier, apply: lambda { |records, value, _options|
        # First we check tubes to see if there are any given the source identifier
        recs = records.joins(:tube).where(tube: { barcode: value })
        return recs unless recs.empty?

        # If no tubes match the source identifier we check plates
        # If source identifier specifies a well we need to match samples to well
        # TODO: The below value[0] means we only take the first value passed in the filter
        #       If we want to support multiple values in one filter we would need to update this
        plate, well = value[0].split(':')
        recs = records.joins(:plate).where(plate: { barcode: plate })
        well ? recs.joins(:well).where(well: { position: well }) : recs
      }
      def self.default_sort
        [{ field: 'created_at', direction: :desc }]
      end

      def created_at
        @model.created_at.to_fs(:us)
      end

      def library_type
        @model.library_type.name
      end

      def library_type=(name)
        @model.library_type = LibraryType.find_by(name:)
      end

      def data_type
        @model.data_type.name
      end

      def data_type=(name)
        @model.data_type = DataType.find_by(name:)
      end

      def self.records_for_populate(*_args)
        super.preload(:library_type, :data_type)
      end
    end
  end
end

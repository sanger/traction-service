# frozen_string_literal: true

module V1
  module Ont
    # RequestResource
    class RequestResource < JSONAPI::Resource
      model_name 'Ont::Request', add_model_hint: false

      attributes(*::Ont.request_attributes, :sample_name, :source_identifier, :created_at)

      paginator :paged

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

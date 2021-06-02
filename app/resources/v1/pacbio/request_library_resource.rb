# frozen_string_literal: true

module V1
  module Pacbio
    # LibraryResource
    class RequestLibraryResource < JSONAPI::Resource
      model_name 'Pacbio::RequestLibrary'

      attributes :sample_name, :tag_oligo, :tag_group_id, :tag_set_name, :tag_id

      def self.records_for_populate(*_args)
        super.preload(tag: :tag_set, request: :sample)
      end
    end
  end
end

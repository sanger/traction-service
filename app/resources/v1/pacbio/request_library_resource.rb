# frozen_string_literal: true

module V1
  module Pacbio
    # LibraryResource
    class RequestLibraryResource < JSONAPI::Resource
      model_name 'Pacbio::RequestLibrary'

      attributes :sample_name, :tag_oligo, :tag_group_id, :tag_set_name, :tag_id
    end
  end
end

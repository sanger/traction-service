# frozen_string_literal: true

module V1
  module Pacbio
    # TagSetResource
    class TagSetResource < JSONAPI::Resource
      model_name 'TagSet'

      attributes :name, :uuid

      has_many :tags
    end
  end
end

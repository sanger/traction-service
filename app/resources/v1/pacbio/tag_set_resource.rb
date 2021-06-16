# frozen_string_literal: true

module V1
  module Pacbio
    # TagSetResource
    class TagSetResource < JSONAPI::Resource
      model_name 'TagSet'

      attributes :name, :uuid

      #TODO: a tag set has many tags which we may need but this creates a circular reference
      # when we are returning tags.

    end
  end
end

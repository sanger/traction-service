# frozen_string_literal: true

module V1
  module Ont
    # TagResource - a resource to return all of the ONT tags
    class TagResource < JSONAPI::Resource
      model_name 'Tag'

      attributes :oligo, :group_id

      has_one :tag_set
    end
  end
end

# frozen_string_literal: true

module V1
  # TagResource
  class TagResource < JSONAPI::Resource
    attributes :oligo, :group_id, :tag_set_id
  end
end

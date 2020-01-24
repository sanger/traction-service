# frozen_string_literal: true

module V1
  # TagResource
  class TagResource < JSONAPI::Resource
    attributes :oligo, :group_id, :tag_set_id

    # originally put 'belongs_to' to match the model, but got following warning from jsonapi:
    # In V1::TagResource you exposed a `has_one` relationship  using the `belongs_to` class method...
    # We think `has_one` is more appropriate. If you know what you're doing, and don't want to see this warning again, override the `belongs_to` class method on your resource.
    has_one :tag_set
  end
end

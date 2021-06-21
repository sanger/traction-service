# frozen_string_literal: true

module V1
  # TagResource
  module Pacbio
    class TagResource < JSONAPI::Resource
      model_name 'Tag'

      attributes :oligo, :group_id

      # originally put 'belongs_to' to match the model, but got following warning from jsonapi:
      # ...you exposed a `has_one` relationship  using the `belongs_to` class method...
      # We think `has_one` is more appropriate... etc.
      has_one :tag_set
    end
  end
end

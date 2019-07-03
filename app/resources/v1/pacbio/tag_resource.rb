# frozen_string_literal: true

module V1
  module Pacbio
    # TagResource
    class TagResource < JSONAPI::Resource
      model_name 'Pacbio::Tag'

      attributes :oligo
    end
  end
end

# frozen_string_literal: true

module V1
  module Pacbio
    # @note There is no access to the material resource via the Pacbio API at this time.
    # It is used via the tube resource.
    # @see {V1::Pacbio::TubeResource}
    class MaterialResource < JSONAPI::Resource
    end
  end
end

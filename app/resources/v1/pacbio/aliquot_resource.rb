# frozen_string_literal: true

module V1
  module Pacbio
    # AliquotResource
    class AliquotResource < V1::AliquotResource
      include Shared::RunSuitability
    end
  end
end

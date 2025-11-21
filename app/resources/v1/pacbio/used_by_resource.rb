# frozen_string_literal: true

module V1
  module Pacbio
    # @note `UsedByResource` supports aliquot polymorphism
    # @note This resource is not accessed directly via a dedicated endpoint.
    # It is accessed via {V1::AliquotResource } relationship.
    #
    class UsedByResource < V1::UsedByResource
    end
  end
end

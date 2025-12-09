# frozen_string_literal: true

# JSON-API resources wont resolve across namespaces spaces
# so we need the Pool resource in the top level namespace to support
# MultiPool to Pool relationships
module V1
  # Provides a JSON:API representation of {PoolResource}. {PoolResource} supports multi pool
  #  polymorphism.
  #
  # @note This resource cannot be directly accessed. Use pipeline specific pool resources instead.
  class PoolResource < JSONAPI::Resource
  end
end

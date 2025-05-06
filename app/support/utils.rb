# frozen_string_literal: true

# This module provides utility methods for the application.
module Utils
  # Converts a hash into a Struct object.
  #
  # This method takes a hash and dynamically creates a Struct with keys as attributes
  # and values as the corresponding attribute values. It allows accessing hash values
  # using dot notation instead of hash syntax.
  #
  # @param hash [Hash] The hash to be converted into a Struct.
  # @return [Struct] A Struct object with attributes corresponding to the hash keys.
  #
  # @example
  #   hash = { name: 'John', age: 30 }
  #   struct = hash_to_struct(hash)
  #   struct.name # => 'John'
  #   struct.age  # => 30
  def hash_to_struct(hash)
    const = Struct.new(*hash.keys.collect(&:to_sym))
    const.new(*hash.values)
  end

  # Converts a hash into a deep Struct object.
  #
  # This method recursively converts nested hashes into Struct objects.
  # It allows accessing nested hash values using dot notation.
  #
  # @param hash [Hash] The hash to be converted into a deep Struct.
  # @return [Struct] A deep Struct object with nested attributes.
  #
  # @example
  #   hash = { name: 'John', age: 30, address: { city: 'New York', zip: '10001' } }
  #   struct = hash_to_deep_struct(hash)
  #   struct.name          # => 'John'
  #   struct.address.city  # => 'New York'
  #   struct.address.zip   # => '10001'
  def hash_to_deep_struct(hash)
    const = Struct.new(*hash.keys.collect(&:to_sym))
    const.new(*hash.values.map { |value| value.is_a?(Hash) ? hash_to_deep_struct(value) : value })
  end
end

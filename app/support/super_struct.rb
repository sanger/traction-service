# frozen_string_literal: true

# SuperStruct is a utility class that wraps a hash in a Struct-like object,
# allowing access to hash keys as attributes. It supports deep nesting,
# enabling nested hashes to be converted into nested Structs.
#
# This class also overrides the `==` method to provide custom equality logic,
# comparing the content of the wrapped hash and the structure of the underlying
# Struct definition.
#
# @example Basic Usage
#   hash = { name: 'John', age: 30 }
#   struct = SuperStruct.new(hash)
#   struct.name # => 'John'
#   struct.age  # => 30
#
# @example Deep Struct
#   hash = { person: { name: 'John', age: 30 }, city: 'New York' }
#   struct = SuperStruct.new(hash, deep: true)
#   struct.person.name # => 'John'
#   struct.city        # => 'New York'
#
# @example Equality
#   hash1 = { name: 'John', age: 30 }
#   hash2 = { name: 'John', age: 30 }
#   struct1 = SuperStruct.new(hash1)
#   struct2 = SuperStruct.new(hash2)
#   struct1 == struct2 # => true
class SuperStruct
  # @return [Struct] The underlying Struct instance.
  attr_reader :instance

  # Semantically equivalent to `respond_to?` for checking if a key exists.
  alias key? respond_to?

  # Initializes a new SuperStruct instance.
  #
  # @param hash [Hash] The hash to wrap in a Struct.
  # @param deep [Boolean] Whether to recursively convert nested hashes into Structs.
  def initialize(hash, deep: false)
    @deep = deep
    @instance = deep ? hash_to_deep_super_struct(hash) : build_const(hash).new(*hash.values)
  end

  # Delegates method calls to the underlying Struct instance, except for `==`.
  #
  # @param method_name [Symbol] The name of the method being called.
  # @param args [Array] The arguments for the method.
  # @param block [Proc] An optional block for the method.
  def method_missing(method_name, *, &)
    if method_name != :== && @instance.respond_to?(method_name)
      @instance.send(method_name, *, &)
    else
      super
    end
  end

  # Checks if the SuperStruct responds to a given method.
  #
  # @param method_name [Symbol] The name of the method.
  # @param include_private [Boolean] Whether to include private methods.
  # @return [Boolean] True if the method is supported, false otherwise.
  def respond_to_missing?(method_name, include_private = false)
    (method_name != :== && @instance.respond_to?(method_name)) || super
  end

  # Compares two SuperStruct objects for equality.
  #
  # @param other [SuperStruct] The other SuperStruct to compare.
  # @return [Boolean] True if the content and structure are equal, false otherwise.
  def ==(other)
    return false unless other.is_a?(SuperStruct)

    deep_to_h(@instance) == deep_to_h(other.instance)
  end

  private

  # Recursively converts a hash into a deep Struct object.
  #
  # @param hash [Hash] The hash to convert.
  # @return [Struct] A Struct object with nested Structs for nested hashes.
  def hash_to_deep_super_struct(hash)
    build_const(hash).new(*hash.values.map do |value|
      value.is_a?(Hash) ? SuperStruct.new(value, deep: true) : value
    end)
  end

  # Recursively converts a Struct or hash into a hash.
  #
  # @param obj [Struct, Hash, Object] The object to convert.
  # @return [Hash, Object] A hash representation of the object,
  # or the object itself if not a Struct or hash.
  def deep_to_h(obj)
    case obj
    when Struct
      obj.to_h.transform_values { |v| deep_to_h(v) }
    when Hash
      obj.transform_values { |v| deep_to_h(v) }
    else
      obj
    end
  end

  # Builds a Struct class definition from the keys of a hash.
  #
  # This method takes a hash and dynamically creates a Struct class
  # where each key in the hash becomes an attribute of the Struct.
  #
  # @param hash [Hash] The hash whose keys will be used to define the Struct attributes.
  # @return [Class] A Struct class with attributes corresponding to the hash keys.
  #
  # @example
  #   hash = { name: 'John', age: 30 }
  #   struct_class = build_const(hash)
  #   struct = struct_class.new('John', 30)
  #   struct.name # => 'John'
  #   struct.age  # => 30
  def build_const(hash)
    Struct.new(*hash.keys.collect(&:to_sym))
  end
end

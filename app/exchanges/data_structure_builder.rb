# frozen_string_literal: true

# Creates a message in the correct structure for the warehouse
module DataStructureBuilder
  extend ActiveSupport::Concern

  include ActiveModel::Model

  included do
    # configuration => Pipelines::Configuration::Item
    attr_accessor :object, :configuration
  end

  def data_structure
    configuration.fields.each_with_object({}) do |(k, v), r|
      r[k] = instance_value(object, v, :root)
    end
  end

  # Find the instance value for each field
  # If the field is a:
  # * [string]    - return the value
  # * [model]     - take the value split it by the full stop
  #                 and recursively send the method to the object
  #                 e.g. it is object.foo.bar will first evaluate
  #                 foo and then apply bar
  # * [parent_model] - as above, but applied to the parent object
  # * [constant]  - Takes the constant and applies the method chain
  #                 to it e.g DateTime.now
  # * [array]     - usually an array of fields
  # * [self]     - applies to the method to the current (builder) object
  def instance_value(object, field, parent = nil) # # rubocop:disable Metrics/MethodLength
    case field[:type]
    when :string
      field[:value]
    when :model
      evaluate_field(object, field[:value])
    when :parent_model
      evaluate_field(parent, field[:value])
    when :constant
      const_obj, *methods = field[:value].split('.')
      evaluate_method_chain(const_obj.constantize, methods)
    when :array
      build_children(object, field)
    when :self
      evaluate_field(self, field[:value])
    end
  end

  # we need to do this via try as certain fields may be nil
  def evaluate_method_chain(object, chain)
    chain.inject(object) { |o, meth| o.try(:send, meth) }
  end

  private

  # If the message contains a number of children for example
  # with Pacbio each well will have a number of samples
  # For each field get the value
  # This is applied to the nested object not the
  # original object
  def build_children(object, field)
    Array(object.send(field[:value])).collect do |o|
      field[:children].each_with_object({}) do |(k, v), r|
        r[k] = instance_value(o, v, object)
      end
    end
  end

  def evaluate_field(object, field_value)
    if field_value.include?('&.')
      evaluate_safe_navigation(object, field_value.split('&.'))
    else
      evaluate_method_chain(object, field_value.split('.'))
    end
  end

  def evaluate_safe_navigation(object, chain)
    chain.inject(object) do |obj, meth|
      break nil unless obj

      if meth.include?('.')
        evaluate_method_chain(obj, meth.split('.'))
      elsif obj.is_a?(Hash)
        # Handle both hash and object cases
        key = meth.to_sym
        obj.key?(key) ? obj[key] : obj[meth.to_s]
      else
        obj.try(:send, meth)
      end
    end
  end
end

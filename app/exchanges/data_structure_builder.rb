# frozen_string_literal: true

# Creates a message in the correct structure for the warehouse
class DataStructureBuilder
  include ActiveModel::Model

  attr_accessor :object, :configuration

  def data_structure
    configuration.fields.each_with_object({}) do |(k, v), r|
      r[k] = instance_value(object, v, :root)
    end
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
  def instance_value(object, field, parent) # rubocop:disable Metrics/MethodLength
    case field[:type]
    when :string
      field[:value]
    when :model
      evaluate_method_chain(object, field[:value].split('.'))
    when :parent_model
      evaluate_method_chain(parent, field[:value].split('.'))
    when :constant
      evaluate_method_chain(field[:value].split('.').first.constantize,
                            field[:value].split('.')[1..])
    when :array
      build_children(object, field)
    end
  end

  # we need to do this via try as certain fields may be nil
  def evaluate_method_chain(object, chain)
    chain.inject(object) { |o, meth| o.try(:send, meth) }
  end
end

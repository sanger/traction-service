# frozen_string_literal: true

module Messages
  # Message
  class Message
    include ActiveModel::Model

    attr_accessor :object, :configuration

    def content
      { lims: configuration.lims }.with_indifferent_access.tap do |result|
        result[configuration.key] = configuration.fields.each_with_object({}) do |(k, v), r|
          r[k] = instance_value(v)
        end
      end
    end

    def payload
      content.to_json
    end

    private

    def instance_value(field)
      case field[:type]
      when :string
        field[:value]
      when :model
        evaluate_method_chain(object, field[:value].split('.'))
      when :constant
        evaluate_method_chain(field[:value].split('.').first.constantize,
                              field[:value].split('.')[1..-1])
      end
    end

    def evaluate_method_chain(object, chain)
      chain.inject(object, :send)
    end
  end
end

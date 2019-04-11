# frozen_string_literal: true

module Messages
  # Message
  class Message
    include ActiveModel::Model

    attr_accessor :object, :configuration

    def timestamp
      Time.current
    end

    # rubocop:disable Metrics/AbcSize
    def content
      {}.tap do |result|
        result[configuration['key']] = configuration['fields'].each_with_object({}) do |(k, v), r|
          r[k] = instance_value(v)
        end
        result[configuration['key']]['updated_at'] = timestamp
        result['lims'] = configuration['lims']
        result['instrument_name'] = configuration['instrument_name']
      end
    end
    # rubocop:enable Metrics/AbcSize

    def payload
      content.to_json
    end

    private

    def instance_value(chain)
      chain.split('.').inject(object, :send)
    end
  end
end

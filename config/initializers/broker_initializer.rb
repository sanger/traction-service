# frozen_string_literal: true

require 'broker'

if Rails.configuration.events[:enabled]
  BrokerHandle = Broker.new
  BrokerHandle.create_connection
  BrokerHandle.publish
else
  # Create an "empty" class definition with fake methods to use when events are disabled
  BrokerHandle = Broker.new.tap do |obj|
    obj.instance_eval do
      # def publish(obj)
      #   puts "***\nPUBLISHING\n#{obj.generate_json}\n***"
      # end
      # def consume; end
      # def working?; end
      # def connected?; end
    end
  end
end

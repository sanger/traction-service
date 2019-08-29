# frozen_string_literal: true

if Rails.configuration.bunny['enabled']
  BrokerHandle = Messages::Broker.new(Rails.configuration.bunny)
  BrokerHandle.create_connection
else
  # Create an "empty" class definition when bunny is disabled
  BrokerHandle = Messages::Broker.new(Rails.configuration.bunny).tap do |obj|
    obj.instance_eval do
    end
  end
end

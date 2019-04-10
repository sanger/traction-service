# frozen_string_literal: true

require 'broker'

if Rails.configuration.bunny['enabled']
  BrokerHandle = Broker.new(Rails.configuration.bunny)
  BrokerHandle.create_connection
else
  # Create an "empty" class definition when bunny are disabled
  BrokerHandle = Broker.new(Rails.configuration.bunny).tap do |obj|
    obj.instance_eval do
    end
  end
end

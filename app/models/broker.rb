# frozen_string_literal: true

# Broker setup
module Broker
  if Rails.configuration.bunny['enabled']
    Handle = Messages::Broker.new(Rails.configuration.bunny)
    Handle.create_connection
  else
    # Create an "empty" class definition when bunny is disabled
    Handle = Messages::Broker.new(Rails.configuration.bunny).tap do |obj|
      obj.instance_eval do
      end
    end
  end
end

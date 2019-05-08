# frozen_string_literal: true

# rabbitmq messages
module Messages
  def self.publish(object, configuration)
    BrokerHandle.publish(Message.new(object: object, configuration: configuration))
  end
end

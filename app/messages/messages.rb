# frozen_string_literal: true

# rabbitmq messages
module Messages
  def self.publish(objects, configuration)
    Array(objects).each do |object|
      BrokerHandle.publish(Message.new(object: object, configuration: configuration))
    end
  end
end

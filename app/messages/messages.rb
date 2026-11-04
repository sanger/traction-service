# frozen_string_literal: true

# rabbitmq messages
module Messages
  # Errors are logged and reported rather than raised so a broker outage cannot fail the
  # request that triggered the message (same approach as Emq::PublishingJob).
  def self.publish(objects, configuration)
    Array(objects).each do |object|
      ::Broker::Handle.publish(Message::Message.new(object:, configuration:))
    end
  rescue StandardError => e
    Rails.logger.error("Failed to publish message to RabbitMQ: #{e.message}")
    ExceptionNotifier.notify_exception(e)
  end
end

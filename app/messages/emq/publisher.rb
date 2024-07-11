# frozen_string_literal: true

# This class should be responsible for sending messages to the EMQ which are validated
# against an Avro schema stored in the RedPanda registry before being sent
module Emq::Publisher
  # Initialize the publisher with the bunny configuration
  def self.publish_job
    return @publish_job if defined?(@publish_job)

    @publish_job = Emq::PublishingJob.new if Rails.configuration.bunny['enabled']
  end

  # Publish a message to the EMQ
  def self.publish(aliquots, configuration, schema_key)
    return if publish_job.nil?

    publish_job.publish(aliquots, configuration, schema_key:)
  end
end

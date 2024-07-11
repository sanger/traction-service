# frozen_string_literal: true

require 'ostruct'

module Emq
  # This class should be responsible for publishing messages to the EMQ which are validated
  # against an Avro schema stored in the RedPanda registry before being sent
  class PublishingJob
    attr_reader :bunny_config

    # Initialize the publishing job with the bunny configuration
    def initialize
      # Load the bunny configuration from the Rails configuration and convert it to an OpenStruct
      @bunny_config = PublishingJob.deep_open_struct(Rails.configuration.bunny)
    end

    # Publish a message to the EMQ
    # @param [Object] objects the object or objects to publish
    # @param [Object] create_messsage_configuration the configuration to construct
    #                                               the message to publish from the given object(s)
    # @param [String] schema_key the key of the schema to validate the message against

    def publish(objects, create_messsage_configuration, schema_key) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      # Check if the schema_key exists in the subjects hash and return early if it does not
      schema = bunny_config.amqp.schemas.subjects[schema_key]
      return if schema.nil?

      # Get the subject and version from the schema and return early if either is nil
      subject = bunny_config.amqp.schemas.subjects[schema_key].subject
      version = bunny_config.amqp.schemas.subjects[schema_key].version
      return if subject.nil? || version.nil?

      # Create a validator and sender for the subject and version
      validator = Emq::Validator.new(subject, version, bunny_config.amqp.schemas.registry_url)
      sender = Emq::Sender.new(bunny_config.amqp.isg, subject, version)

      # Publish each object to the EMQ
      Array(objects).each do |object|
        # Construct the message to publish from the object using the given configuration
        message_object = Message::Message.new(object:,
                                              configuration: create_messsage_configuration).content

        # check if the schema_key is present in the payload
        next if message_object[schema_key].nil?

        # Validate the message against the schema and send it to the EMQ
        publish_message = message_object[schema_key]
        message = validator.validate_message(publish_message)
        sender.send_message(message)
      end
    end

    # recursively converts a nested hash into an OpenStruct,
    # allowing for dot notation access to hash keys and their values.
    def self.deep_open_struct(obj)
      return obj unless obj.is_a?(Hash)

      OpenStruct.new(obj.transform_values { |val| deep_open_struct(val) }) # rubocop:disable Style/OpenStructUse
    end
  end
end

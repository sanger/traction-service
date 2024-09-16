# frozen_string_literal: true

require 'ostruct'

module Emq
  # This class should be responsible for publishing messages to the EMQ which are validated
  # against an Avro schema stored in the RedPanda registry before being sent
  class PublishingJob
    attr_reader :bunny_config

    # The prefix for the key which contains the version of the Avro schema to use
    # by the message builder
    AVRO_SCHEMA_VERSION_KEY = 'avro_schema_version_'

    # Initialize the publishing job with the bunny configuration
    def initialize
      # Load the bunny configuration from the Rails configuration and convert it to an OpenStruct
      @bunny_config = PublishingJob.deep_open_struct(Rails.configuration.bunny)
    end

    # Publish a message to the EMQ
    # @param [Object] objects the object or objects to publish
    # @param [Object] the pipeline configuration to construct
    #                 the message to publish from the given object(s)
    # @param [String] schema_key the key of the schema to validate the message against
    # Note:-
    # The schema_key must exist within the subjects hash of the bunny configuration and
    # must also have a matching configuration within the pipeline settings.
    # (See the 'volume_tracking' section in config/pipelines/pacbio.yml for reference.)
    # Any messages published using publishing_job require a corresponding entry in the
    # pipeline configuration, identified by the schema key.
    #
    def publish(objects, message_config, schema_key) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity
      # Check if the schema_key exists in the subjects hash and return early if it does not
      schema = bunny_config.amqp.schemas.subjects[schema_key]
      return if schema.nil?

      # Get the subject and version from the schema and return early if either is nil
      subject = bunny_config.amqp.schemas.subjects[schema_key].subject
      version = bunny_config.amqp.schemas.subjects[schema_key].version
      return if subject.nil? || version.nil?

      # Get the message builder configuration for the schema key and version
      # and create a message builder class from the configuration
      message_builder_config_obj = message_builder_config(message_config, schema_key, version)
      if message_builder_config_obj.nil?
        Rails.logger.error('Message builder configuration not found for ' \
                           "schema key: #{schema_key} and version: #{version}")
        return
      end
      message_builder_class = message_builder_config_obj.message_class.to_s.constantize

      # Create a validator and sender for the subject and version
      encoder = Emq::Encoder.new(subject, version, bunny_config.amqp.schemas.registry_url)
      sender = Emq::Sender.new(bunny_config.amqp.isg, subject, version)

      begin
        # Publish each object to the EMQ
        Array(objects).each do |object|
          # Construct the message to publish from the object using the given configuration
          message_object = message_builder_class.new(object:,
                                                     configuration: message_builder_config_obj)
                                                .content

          # check if the schema_key is present in the payload
          next if message_object[schema_key].nil?

          # Validate the message against the schema and send it to the EMQ
          publish_message = message_object[schema_key]
          message = encoder.encode_message(publish_message)
          sender.send_message(message)
        end
        # Log success message after successful publishing
        Rails.logger.info('Published volume tracking message to EMQ')
      rescue StandardError => e
        # Raise an exception if any error occurs
        Rails.logger.error("Failed to publish message to EMQ: #{e.message}")
      end
    end

    # recursively converts a nested hash into an OpenStruct,
    # allowing for dot notation access to hash keys and their values.
    def self.deep_open_struct(obj)
      return obj unless obj.is_a?(Hash)

      OpenStruct.new(obj.transform_values { |val| deep_open_struct(val) }) # rubocop:disable Style/OpenStructUse
    end

    private

    # Get the message builder configuration for the schema key and version
    # @param [Object] message_config the pipeline configuration to get the message builder
    #                                configuration from
    # @param [String] schema_key the key of the schema to get the message builder configuration for
    # @param [Integer] version the version of the schema to get the message builder configuration
    # @return [OpenStruct | nil] the message builder configuration for the schema key and version
    # the builder configuratin should be in the format:

    def message_builder_config(message_config, schema_key, version)
      children = message_config.public_send(schema_key)&.instance_variable_get(:@children)
      return unless children

      builder_config = children["#{AVRO_SCHEMA_VERSION_KEY}#{version}"]
      return unless builder_config

      OpenStruct.new(builder_config) # rubocop:disable Style/OpenStructUse
    end
  end
end

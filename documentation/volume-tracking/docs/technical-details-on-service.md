# Technical Details of Traction Service that allows message publishing

The two classes central to sending volume tracking messages to the message broker are [`app/messages/emq/publisher.rb`](https://github.com/sanger/traction-service/blob/21fd7c20ec7c9a329914a53968aa23c4a6dac4af/app/messages/emq/publisher.rb) and [`app/messages/emq/publishing_job.rb`](https://github.com/sanger/traction-service/blob/a2e3e693ccacb1b4b5be31be56c5346f97c929d9/app/messages/emq/publishing_job.rb). The former defines functions to instantiate an `Emq::PublishingJob` object, and the latter defines business logic on how message publishing should occur. The former is a trivial implementation on instantiating a Ruby object based on a configuration (`enabled` in `bunny.yml`); therefore it is not discussed here. However, the latter has some points that are worthy of some explaination. `Emq::PublishingJob` class' `publish` method is documented in `traction-service` [documentation](https://sanger.github.io/traction-service/Emq/PublishingJob.html#:~:text=Instance%20Method%20Details-,%23publish(objects%2C%20message_config%2C%20schema_key)%20%E2%87%92%20Object,-Publish%20a%20message).

???+ tip linenums="1"

    Each noteworthy code fragment/line is explained in tooltips that could be viewed by clicking on the right arrow symbol (:material-arrow-right-circle:) right hand side of the code line.

```rb title="publish method in app/messages/emq/publishing_job.rb"
def publish(objects, message_config, schema_key)
      # Check if the schema_key exists in the subjects hash and return early if it does not
      schema = bunny_config.amqp.schemas.subjects[schema_key]   # (1)
      return if schema.nil?

      # Get the subject and version from the schema and return early if either is nil
      subject = bunny_config.amqp.schemas.subjects[schema_key].subject  # (7)
      version = bunny_config.amqp.schemas.subjects[schema_key].version  # (5)
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
      encoder = Emq::Encoder.new(subject, version, bunny_config.amqp.schemas.registry_url) # (2)
      sender = Emq::Sender.new(bunny_config.amqp.isg, subject, version) # (3)

      begin
        # Publish each object to the EMQ
        Array(objects).each do |object| # (6)
          # Construct the message to publish from the object using the given configuration
          message_object = message_builder_class.new(object:,
                                                     configuration: message_builder_config_obj)
                                                .content # (4)

          # check if the schema_key is present in the payload
          next if message_object[schema_key].nil?

          # Validate the message against the schema and send it to the EMQ
          publish_message = message_object[schema_key]
          message = encoder.encode_message(publish_message)
          sender.send_message(message)
        end
        # Log success message after successful publishing
        Rails.logger.info('Published volume tracking message to EMQ')   # (8)
      rescue StandardError => e
        # Raise an exception if any error occurs
        raise "Failed to publish message to EMQ: #{e.message}"
      end
    end
```

1. `bunny_config` refers to the `config/bunny.yml` file.
2. `Emq::Encoder` encodes messages into a binary format using `avro` schemas stored in RedPanda Schema Registry.
3. `Emq::Sender` uses the `version` and `subject` to populate the headers of the AMQP message.
4. `message_object` refers to a dynamically generated (and populated) Ruby object that uses the object schema defined in [config/pipelines/pacbio.yml](https://github.com/sanger/traction-service/blob/de2f6e229d4f2621224fa7d5d5cf994d4e4d0e21/config/pipelines/pacbio.yml#L302-L353).
5. The schema defined in [RedPanda Schema Registry](https://redpanda.psd.sanger.ac.uk/console/schema-registry) is fetched using the REST API provided by RedPanda, and the message is encoded into a binary format.
6. Each object is published into the broker in a loop, separately.
7. Subject refers to the schema name in RedPanda Schema Registry.
8. Message publishing event is logged for monitoring purposes.

The message is published to the configured RabbitMQ broker. The broker's configuration are declared under the YAML key `bunny_config.amqp` in `config/bunny.yml`.

!!! warning 

    Note that if `traction-service` is not able to find the schema from the schema registry, or not able to find either the `subject` or `version` declared in `bunny.yml`, no message will be pushed to the queue. Therefore, correct configuration is essential for a successful end-to-end volume tracking process.

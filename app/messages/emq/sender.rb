# frozen_string_literal: true

require 'bunny'

module Emq
  # This class should be responsible for sending messages to the EMQ
  class Sender
    attr_reader :config, :subject, :version

    # Initialize the sender with the configuration, subject and version
    # @param [Hash] config the configuration for the sender
    # @param [String] subject the subject of the schema that the message is validated against
    # @param [String] version the version of the schema that the message is validated against
    def initialize(config, subject, version)
      @config = config
      @subject = subject
      @version = version
    end

    # Send a message to the EMQ
    # @param [String] message the message to send
    def send_message(message) # rubocop:disable Metrics/MethodLength
      conn = Bunny.new(connection_params)
      conn.start

      begin
        channel = conn.create_channel
        exchange = channel.headers(config.exchange, passive: true)
        headers = { subject:, version:, encoder_type: 'binary' }
        exchange.publish(message, headers:, persistent: true)
      rescue Bunny::TCPConnectionFailed, Bunny::NetworkFailure => e
        # Log the error with message identifier
        Rails.logger.error("Failed to send message with ID #{message.messageUuid}: #{e.message}")
        raise
      ensure
        conn.close
      end
    end

    private

    # Create the connection parameters
    def connection_params
      connection_params = {
        host: config.host,
        username: config.username,
        password: config.password,
        vhost: config.vhost
      }

      if config.tls
        add_tls_params(connection_params)
      else
        connection_params
      end
    end

    # Add TLS parameters to the connection parameters
    def add_tls_params(connection_params)
      connection_params[:tls] = true

      begin
        connection_params[:tls_ca_certificates] = [config.ca_certificate!]
      rescue Configatron::UndefinedKeyError
        # Should not be the case in production!
        connection_params[:verify_peer] = false
      end

      connection_params
    end
  end
end

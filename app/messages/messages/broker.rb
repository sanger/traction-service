# frozen_string_literal: true

require 'bunny'

module Messages
  # This class should control connection, exchange, queues and publishing to the broker
  class Broker
    attr_accessor :connection
    attr_reader :channel, :queue, :exchange, :bunny_config

    def initialize(bunny_config)
      @bunny_config = SuperStruct.new(bunny_config)
    end

    def create_connection
      connected? || connect
    end

    def connected?
      @connection&.connected?
    end

    def connect
      connect!
    end

    def connect!
      start_connection
      open_channel
      instantiate_exchange
      declare_queue
      bind_queue
    end

    def start_connection
      @connection = Bunny.new host: bunny_config.broker_host,
                              port: bunny_config.broker_port,
                              username: bunny_config.broker_username,
                              password: bunny_config.broker_password,
                              vhost: bunny_config.vhost
      @connection.start
    end

    def open_channel
      @channel = @connection.create_channel
    end

    def instantiate_exchange
      @exchange = @channel.topic(bunny_config.exchange, passive: true)
    end

    def declare_queue
      @queue = @channel.queue(bunny_config.queue_name, durable: true)
    end

    def bind_queue
      @queue.bind(@exchange, routing_key: bunny_config.routing_key)
    end

    def publish(message)
      @exchange&.publish(message.payload, routing_key: bunny_config['routing_key'])
    end
  end
end

# frozen_string_literal: true

require 'bunny'
require 'ostruct'

# This class should control connection, exchange, queues and publishing to the broker
class Broker
  attr_accessor :connection
  attr_reader :channel, :queue, :exchange

  # initialize events_config with host, port, user, exchange, queue etc
  def initialize
    @events_config = OpenStruct.new(Rails.configuration.events)
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
    @connection = Bunny.new host: @events_config.broker_host,
                            port: @events_config.broker_port,
                            username: @events_config.broker_username,
                            password: @events_config.broker_password,
                            vhost: @events_config.vhost
    @connection.start
  end

  def open_channel
    @channel = @connection.create_channel
  end

  def instantiate_exchange
    @exchange = @channel.topic(@events_config.exchange, passive: true)
  end

  def declare_queue
    @queue = @channel.queue(@events_config.queue_name, durable: true)
  end

  def bind_queue
    @queue.bind(@exchange, routing_key: @events_config.routing_key)
  end

  def publish(message)
    @exchange&.publish(message.generate_json, routing_key: @events_config.routing_key)
  end
end

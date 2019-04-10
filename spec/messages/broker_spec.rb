# frozen_string_literal: true
require "rails_helper"

RSpec.describe Messages::Broker do
  let(:bunny) { double('Bunny') }

  let(:params) do
    {
      enabled: true,
      broker_host: 'broker_host',
      broker_port: 'broker_port',
      broker_username: 'broker_username',
      broker_password: 'broker_password',
      vhost: 'vhost',
      exchange: 'exchange',
      queue_name: 'queue_name',
      routing_key: 'routing_key'
    }
  end

  let(:channel) { double('channel') }
  let(:connection) { double('connection') }
  let(:exchange) { double('exchange') }
  let(:queue) { double('queue') }

  let(:config) { Rails.configuration.bunny }
  let(:broker) { Broker.new(config) }

  setup do
    stub_const('Bunny', bunny)
  end

  def mock_connection
    mock_connection_setup
    mock_publishing_setup
    mock_subscribing_setup
  end

  # Mock set-up
  def mock_connection_setup
    allow(bunny).to receive(:new).and_return(connection)
    allow(connection).to receive(:start)
    allow(connection).to receive(:create_channel).and_return(channel)
    allow(channel).to receive(:topic).and_return(exchange)
    allow(channel).to receive(:queue).and_return(queue)
    allow(queue).to receive(:bind)
  end

  # Mock publishing
  def mock_publishing_setup
    allow(exchange).to receive(:publish)
  end

  # Mock queue subscription
  def mock_subscribing_setup
    allow(queue).to receive(:subscribe)
  end

  describe '#create_connection' do
    it 'should not do anything when already connected' do
      mock_connection
      allow(connection).to receive(:connected?).and_return(true)

      broker.create_connection
      expect(broker).not_to receive(:connect)
    end

    it 'should connect when not already connected' do
      expect(broker).to receive(:connect)
      broker.create_connection
    end
  end

  describe '#connected?' do
    it 'should return true when the broker is connected' do
      mock_connection

      broker.create_connection
      allow(connection).to receive(:connected?).and_return(true)
      expect(broker.connected?).to be_truthy
    end

    it 'should return false when the broken is not connected' do
      expect(broker.connected?).to be_falsey
    end
  end

  describe '#connect' do
    it 'creates a connection' do
      mock_connection

      expect(bunny).to receive(:new)
      expect(connection).to receive(:start)
      expect(connection).to receive(:create_channel)
      expect(channel).to receive(:topic)
      expect(channel).to receive(:queue)
      expect(queue).to receive(:bind)
      # expect(queue).to receive(:subscribe)

      broker.create_connection
    end
  end

  describe '#publish' do

    it 'should publish the message' do
      mock_connection
      allow(exchange).to receive(:publish)
      broker.publish('message')
    end
  end

end

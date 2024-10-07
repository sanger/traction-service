# frozen_string_literal: true

require 'rails_helper'
require 'ostruct'
RSpec.describe Emq::Sender do
  let(:encoded_message) { 'encoded_message' }
  let(:mock_bunny) { instance_double(Bunny::Session, start: nil, create_channel: mock_channel, close: nil) }
  let(:mock_channel) { instance_double(Bunny::Channel, headers: mock_exchange) }
  let(:mock_exchange) { instance_double(Bunny::Exchange, publish: nil) }
  let(:bunny_config) do
    {
      amqp: {
        broker: {
          host: 'localhost',
          tls: false,
          vhost: 'tol',
          username: 'admin',
          password: 'development',
          exchange: 'traction'
        },
        schemas: {
          registry_url: 'http://test-redpanda/subjects/',
          subjects: {
            volume_tracking: {
              subject: 'create-aliquot-in-mlwh',
              version: 1
            }
          }
        }
      }
    }
  end
  let(:bunny_config_obj) { Emq::PublishingJob.deep_open_struct(bunny_config) }
  let(:schema_subject) { bunny_config_obj.amqp.schemas.subjects.volume_tracking.subject }
  let(:schema_version) { bunny_config_obj.amqp.schemas.subjects.volume_tracking.version }
  let(:emq_config) { bunny_config_obj.amqp.broker }
  let(:sender) { described_class.new(emq_config, schema_subject, schema_version) }

  describe '#send_message' do
    let(:encoded_message) { 'encoded_message' }

    before do
      allow(Bunny).to receive(:new).and_return(mock_bunny)
      allow(Rails.logger).to receive(:error).and_call_original
    end

    it 'creates a valid connection to the AMQP broker' do
      sender.send_message(encoded_message)

      expect(Bunny).to have_received(:new).with( # rubocop:disable RSpec/MessageSpies
        host: emq_config.host,
        username: emq_config.username,
        password: emq_config.password,
        vhost: emq_config.vhost
      )
    end

    it('updates the connection with TLS parameters if the configuration has empty ca_certificate') do
      emq_config_hash = emq_config.to_h.merge(tls: true)
      emq_config_tls = OpenStruct.new(emq_config_hash) # rubocop:disable Style/OpenStructUse
      updated_sender = described_class.new(emq_config_tls, schema_subject, schema_version)
      updated_sender.send_message(encoded_message)
      expect(Bunny).to have_received(:new).with( # rubocop:disable RSpec/MessageSpies
        host: emq_config.host,
        username: emq_config.username,
        password: emq_config.password,
        vhost: emq_config.vhost,
        tls: true,
        verify_peer: false
      )
    end

    it('updates the connection with TLS parameters if the configuration has a ca_certificate') do
      emq_config_hash = emq_config.to_h.merge(tls: true,
                                              ca_certificate: 'ca_certificate')
      emq_config_tls = OpenStruct.new(emq_config_hash) # rubocop:disable Style/OpenStructUse
      updated_sender = described_class.new(emq_config_tls, schema_subject, schema_version)
      updated_sender.send_message(encoded_message)
      expect(Bunny).to have_received(:new).with( # rubocop:disable RSpec/MessageSpies
        host: emq_config.host,
        username: emq_config.username,
        password: emq_config.password,
        vhost: emq_config.vhost,
        tls: true,
        tls_ca_certificates: ['ca_certificate']
      )
    end

    it 'sends the encoded message to the AMQP broker' do
      sender.send_message(encoded_message)
      expect(mock_exchange).to have_received(:publish).with( # rubocop:disable RSpec/MessageSpies
        encoded_message,
        headers: { subject: schema_subject, version: schema_version, encoder_type: 'binary' },
        persistent: true
      )
    end

    it 'closes the connection after sending the message' do
      sender.send_message(encoded_message)

      expect(mock_bunny).to have_received(:close) # rubocop:disable RSpec/MessageSpies
    end

    it 'closes the connection even if an error is raised' do
      allow(mock_exchange).to receive(:publish).and_raise('An error')

      expect { sender.send_message(encoded_message) }.to raise_error('An error')
      expect(mock_bunny).to have_received(:close) # rubocop:disable RSpec/MessageSpies
    end
  end
end

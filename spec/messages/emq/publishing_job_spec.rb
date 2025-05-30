# frozen_string_literal: true

require 'rails_helper'

require 'webmock/rspec'

RSpec.describe Emq::PublishingJob do
  let(:pacbio_library) { create(:pacbio_library) }
  let(:pacbio_pool) { create(:pacbio_pool) }
  let(:aliquot) { build(:aliquot, uuid: SecureRandom.uuid, source: pacbio_library, used_by: pacbio_pool, created_at: Time.zone.now, updated_at: Time.zone.now) }

  let(:publishing_job) { described_class.new }
  let(:emq_sender_mock) { instance_double(Emq::Sender) }

  let(:registry_url) { 'http://test-redpanda/subjects/' }
  let(:bunny_config) do
    {
      enabled: false,
      broker_host: 'localhost',
      broker_port: 5672,
      broker_username: 'guest',
      broker_password: 'guest',
      vhost: '/',
      exchange: 'bunny.examples.exchange',
      queue_name: 'psd.traction.to-warehouse',
      routing_key: nil,
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
              version: 2
            }
          }
        }
      }
    }
  end
  let(:bunny_config_obj) { SuperStruct.new(bunny_config, deep: true) }

  let(:subject_obj) { 'create-aliquot-in-mlwh' }
  let(:version_obj) { 2 }

  let(:volume_tracking_avro_response) do
    allow(Rails.configuration).to receive(:bunny).and_return(bunny_config)
    Rails.root.join('spec/fixtures/volume_tracking_avro_response.json').read
  end

  before do
    allow(Emq::Sender).to receive(:new).with(bunny_config_obj.amqp.broker, subject_obj, version_obj).and_return(emq_sender_mock)
    allow(emq_sender_mock).to receive(:send_message).with(anything)
    stub_request(:get, "#{registry_url}#{subject_obj}/versions/#{version_obj}")
      .to_return(status: 200, body: volume_tracking_avro_response, headers: {})
  end

  it 'initialises schema key and configuration' do
    expect(publishing_job.bunny_config).to eq(bunny_config_obj)
  end

  it 'publishes a single message' do
    expect(emq_sender_mock).to receive(:send_message).once
    expect(Rails.logger).to receive(:info).with('Published volume tracking message to EMQ')
    publishing_job.publish(aliquot, Pipelines.pacbio, 'volume_tracking')
  end

  it 'can publish multiple messages' do
    expect(emq_sender_mock).to receive(:send_message).twice
    expect(Rails.logger).to receive(:info).with('Published volume tracking message to EMQ')
    aliquot2 = build(:aliquot, uuid: SecureRandom.uuid, source: pacbio_library, used_by: pacbio_pool, created_at: Time.zone.now, updated_at: Time.zone.now)

    publishing_job.publish([aliquot, aliquot2], Pipelines.pacbio, 'volume_tracking')
  end

  it 'does not publish messages when schema key is missing in config' do
    expect(emq_sender_mock).not_to receive(:send_message)
    aliquot2 = build(:aliquot, uuid: SecureRandom.uuid, source: pacbio_library, used_by: pacbio_pool, created_at: Time.zone.now, updated_at: Time.zone.now)
    publishing_job.publish([aliquot, aliquot2], Pipelines.pacbio, 'test')
  end

  it 'logs an error when the message building config misses the given avro schema version' do
    bunny_config[:amqp][:schemas][:subjects][:volume_tracking][:version] = 3
    expect(emq_sender_mock).not_to receive(:send_message)
    expect(Rails.logger).to receive(:error).with('Message builder configuration not found for schema key: volume_tracking and version: 3')
    publishing_job.publish(aliquot, Pipelines.pacbio, 'volume_tracking')
  end

  it 'logs error message when the EMQ is down' do
    allow(emq_sender_mock).to receive(:send_message).and_raise(StandardError)
    expect(Rails.logger).to receive(:error).with('Failed to publish message to EMQ: StandardError')
    publishing_job.publish(aliquot, Pipelines.pacbio, 'volume_tracking')
  end
end

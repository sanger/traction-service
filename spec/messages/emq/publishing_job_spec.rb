# frozen_string_literal: true

require 'rails_helper'

require 'webmock/rspec'

RSpec.describe Emq::PublishingJob do
  let(:pacbio_library) { create(:pacbio_library) }
  let(:pacbio_pool) { create(:pacbio_pool) }
  let(:aliquot) { build(:aliquot, source: pacbio_library, used_by: pacbio_pool, created_at: Time.zone.now) }

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
        isg: {
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
  let(:bunny_config_obj) { described_class.deep_open_struct(bunny_config) }

  let(:subject_obj) { 'create-aliquot-in-mlwh' }
  let(:version_obj) { 1 }

  let(:volume_tracking_avro_response) do
    allow(Rails.configuration).to receive(:bunny).and_return(bunny_config)
    Rails.root.join('spec/fixtures/volume_tracking_avro_response.json').read
  end

  before do
    allow(Emq::Sender).to receive(:new).with(bunny_config_obj.amqp.isg, subject_obj, version_obj).and_return(emq_sender_mock)
    allow(emq_sender_mock).to receive(:send_message).with(anything)
    stub_request(:get, "#{registry_url}#{subject_obj}/versions/#{version_obj}")
      .to_return(status: 200, body: volume_tracking_avro_response, headers: {})
  end

  it 'initialises schema key and configuration' do
    expect(publishing_job.bunny_config).to eq(described_class.deep_open_struct(bunny_config))
  end

  it 'publishes a single message' do
    expect(emq_sender_mock).to receive(:send_message).once
    publishing_job.publish(aliquot, Pipelines.pacbio.volume_tracking, 'volume_tracking')
  end

  it 'can publish multiple messages' do
    expect(emq_sender_mock).to receive(:send_message).twice
    aliquot2 = build(:aliquot, source: pacbio_library, used_by: pacbio_pool, created_at: Time.zone.now)
    publishing_job.publish([aliquot, aliquot2], Pipelines.pacbio.volume_tracking, 'volume_tracking')
  end

  it 'does not publish messages when schema key is missing in config' do
    expect(emq_sender_mock).not_to receive(:send_message)
    aliquot2 = build(:aliquot, source: pacbio_library, used_by: pacbio_pool, created_at: Time.zone.now)
    publishing_job.publish([aliquot, aliquot2], Pipelines.pacbio.volume_tracking, 'test')
  end

  it 'returns open struct object' do
    deep_struct = described_class.deep_open_struct(bunny_config)
    assert_equal 'localhost', deep_struct.amqp.isg.host
    assert_equal false, deep_struct.amqp.isg.tls
    assert_equal 'tol', deep_struct.amqp.isg.vhost
    assert_equal 'admin', deep_struct.amqp.isg.username
    assert_equal 'development', deep_struct.amqp.isg.password
    assert_equal 'traction', deep_struct.amqp.isg.exchange
    assert_equal 'http://test-redpanda/subjects/', deep_struct.amqp.schemas.registry_url
    assert_equal 'create-aliquot-in-mlwh', deep_struct.amqp.schemas.subjects.volume_tracking.subject
    assert_equal 1, deep_struct.amqp.schemas.subjects.volume_tracking.version
  end
end

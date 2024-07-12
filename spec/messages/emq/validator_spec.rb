# frozen_string_literal: true

require 'rails_helper'
require 'ostruct'

require 'webmock/rspec'

RSpec.describe Emq::Validator do
  let(:bunny_config) { Emq::PublishingJob.deep_open_struct(Rails.configuration.bunny) }
  let(:pacbio_library) { create(:pacbio_library) }
  let(:pacbio_pool) { create(:pacbio_pool) }
  let(:aliquot) { build(:aliquot, source: pacbio_library, used_by: pacbio_pool, created_at: Time.zone.now) }
  let(:cache_file_path) { "data/avro_schema_cache/#{schema_subject}_v#{schema_version}.avsc" }
  let(:schema_key) { 'volume_tracking' }
  let(:schema_subject) { bunny_config.amqp.schemas.subjects[schema_key].subject }
  let(:schema_version) { bunny_config.amqp.schemas.subjects[schema_key].version }
  let(:registry_url) { 'http://test-redpanda/subjects/' }
  let(:avro_validator) { described_class.new(schema_subject, schema_version, registry_url) }
  let(:message_data) { Message::Message.new(object: aliquot, configuration: Pipelines.pacbio.volume_tracking).content[schema_key] }

  let(:volume_tracking_avro_response) do
    Rails.root.join('spec/fixtures/volume_tracking_avro_response.json').read
  end

  describe 'validator' do
    context 'when the schema is not cached' do
      before do
        allow(Rails.logger).to receive(:debug).and_call_original # Ensure other debug calls work as expected
        stub_request(:get, "#{registry_url}#{schema_subject}/versions/#{schema_version}")
          .to_return(status: 200, body: volume_tracking_avro_response, headers: {})
      end

      it 'fetches schema from registry' do
        FileUtils.rm_f(cache_file_path)
        expect(Rails.logger).to receive(:debug) do |&block|
          expect(block.call).to eq("Fetching and caching schema for #{schema_subject} v#{schema_version}")
        end
        avro_validator.validate_message(message_data)
      end

      it 'creates a cache file' do
        expect(File).to exist(cache_file_path)
      end
    end

    context 'when the schema cannot be fetched' do
      before do
        # Mock HTTP requests to the schema registry
        stub_request(:get, "#{registry_url}#{schema_subject}/versions/#{schema_version}")
          .to_return(status: 404, body: '', headers: {})
      end

      it 'raises an error' do
        expect { export_job.get_message_schema(schema_subject, schema_version) }.to raise_error(StandardError)
      end
    end

    context 'when the schema is cached' do
      before do
        allow(Rails.logger).to receive(:debug).and_call_original # Ensure other debug calls work as expected
      end

      it 'uses schema from cache' do
        expect(Rails.logger).to receive(:debug) do |&block|
          expect(block.call).to eq("Using cached schema for #{schema_subject} v#{schema_version}")
        end
        avro_validator.validate_message(message_data)
      end
    end

    it 'passes validation' do
      expect { avro_validator.validate_message(message_data) }.not_to raise_error
      expect(avro_validator.validate_message(message_data)).to be_truthy
    end

    it 'fails validation' do
      library = create(:pacbio_library)
      aliquot = build(:aliquot, used_by: pacbio_library, source: library, created_at: '')
      message_data = Message::Message.new(object: aliquot, configuration: Pipelines.pacbio.volume_tracking).content[schema_key]

      # Assuming `validate_message` raises an error on failure
      expect { avro_validator.validate_message(message_data) }.to raise_error(NoMethodError)
    end
  end
end